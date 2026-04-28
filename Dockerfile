FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1

# uvをコピー
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        g++ \
        libfreetype6 \
        libpng-dev \
        fonts-noto-cjk \
        fontconfig \
    && fc-cache -fv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

# 依存関係定義ファイルを先にコピー(キャッシュ効率化)
COPY pyproject.toml uv.lock /work/

# ロックファイル通りに同期(--frozenでロックファイルの更新を禁止)
RUN uv sync --frozen --no-cache

# 仮想環境のbinをPATHに追加
ENV PATH="/work/.venv/bin:$PATH"

EXPOSE 8888

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--LabApp.token=''"]