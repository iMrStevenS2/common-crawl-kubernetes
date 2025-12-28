import os
import time
from warcio.archiveiterator import ArchiveIterator
from bs4 import BeautifulSoup

RAW_DIR = "/data/raw"
CLEAN_DIR = "/data/clean"

MAX_PART_SIZE = 5 * 1024 * 1024  # 5 MB

def process_file(filename, worker_id):
    part = 0
    current_size = 0
    buffer = []

    base = os.path.join(CLEAN_DIR, f"{filename}.part")

    def flush():
        nonlocal part, current_size, buffer
        if not buffer:
            return
        out_file = f"{base}{part}.txt"
        with open(out_file, "a", encoding="utf-8") as f:
            f.write("\n".join(buffer) + "\n")
        buffer.clear()
        current_size = 0
        part += 1

    with open(os.path.join(RAW_DIR, filename), "rb") as stream:
        for record in ArchiveIterator(stream):
            if record.rec_type != "response":
                continue

            try:
                html = record.content_stream().read()
                soup = BeautifulSoup(html, "lxml")

                for tag in soup(["script", "style", "noscript"]):
                    tag.decompose()

                text = soup.get_text(" ", strip=True).lower()

                if len(text) > 200:
                    chunk = text[:5000]
                    buffer.append(chunk)
                    current_size += len(chunk.encode("utf-8"))

                if current_size >= MAX_PART_SIZE:
                    flush()

            except Exception:
                continue

    flush()
    print(f"✔ {filename}: {part} fragmentos generados")


def main():
    WORKER_ID = int(os.getenv("WORKER_ID", 0))
    TOTAL_WORKERS = int(os.getenv("TOTAL_WORKERS", 2))

    start = time.time()
    os.makedirs(CLEAN_DIR, exist_ok=True)

    files = sorted(f for f in os.listdir(RAW_DIR) if f.endswith(".warc.gz"))
    files = files[WORKER_ID::TOTAL_WORKERS]

    print(f"🔥 Worker {WORKER_ID} procesando: {files}")

    for filename in files:
        process_file(filename, WORKER_ID)

    end = time.time()
    print(f"⏱ Worker {WORKER_ID} total: {end - start:.2f}s")


if __name__ == "__main__":
    main()
