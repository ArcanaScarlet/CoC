"""PL用ハンドアウト画像を生成（かじられたリンゴマーク・黒須の名刺）。"""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).parent
MARK_COLOR = (107, 46, 31, 255)
MARK_STROKE = (74, 31, 20, 255)
STEM = (61, 92, 46, 255)
CARD_BG = (26, 26, 26, 255)
CARD_BORDER = (51, 51, 51, 255)
TEXT_MAIN = (232, 224, 213, 255)
TEXT_SUB = (154, 144, 136, 255)
TEXT_NAME = (196, 184, 168, 255)


def draw_bitten_apple(draw: ImageDraw.ImageDraw, cx: int, cy: int, scale: float) -> None:
    """左側がかじられたリンゴ（BadAppleマーク）。"""
    w = int(80 * scale)
    h = int(96 * scale)
    left = cx - w // 2
    top = cy - h // 2 + int(8 * scale)

    draw.ellipse([left, top, left + w, top + h], fill=MARK_COLOR, outline=MARK_STROKE, width=max(1, int(2 * scale)))

    bite_r = int(22 * scale)
    bite_cx = left + int(18 * scale)
    bite_cy = top + int(38 * scale)
    draw.ellipse(
        [bite_cx - bite_r, bite_cy - bite_r, bite_cx + bite_r, bite_cy + bite_r],
        fill=(0, 0, 0, 0),
    )
    draw.chord(
        [bite_cx - bite_r, bite_cy - bite_r, bite_cx + bite_r, bite_cy + bite_r],
        start=200,
        end=340,
        fill=(0, 0, 0, 0),
    )
    # かじりくぼみ（背景色で上書き用に後から貼る場合は透過）
    bite_mask_points = []
    for deg in range(200, 341, 4):
        rad = math.radians(deg)
        bite_mask_points.append(
            (bite_cx + bite_r * math.cos(rad), bite_cy + bite_r * math.sin(rad))
        )
    bite_mask_points.append((bite_cx, bite_cy - bite_r))
    draw.polygon(bite_mask_points, fill=(0, 0, 0, 0))

    stem_w = max(2, int(4 * scale))
    stem_h = int(14 * scale)
    draw.rectangle([cx - stem_w // 2, top - stem_h, cx + stem_w // 2, top + int(4 * scale)], fill=STEM)
    leaf_r = int(8 * scale)
    draw.ellipse([cx + int(2 * scale), top - stem_h - leaf_r, cx + leaf_r * 2, top - stem_h + leaf_r], fill=STEM)


def draw_bitten_apple_opaque(draw: ImageDraw.ImageDraw, cx: int, cy: int, scale: float, bg: tuple[int, ...]) -> None:
    """不透明背景向け：かじりを背景色で抜く。"""
    w = int(80 * scale)
    h = int(96 * scale)
    left = cx - w // 2
    top = cy - h // 2 + int(8 * scale)
    draw.ellipse([left, top, left + w, top + h], fill=MARK_COLOR, outline=MARK_STROKE, width=max(1, int(2 * scale)))
    bite_r = int(22 * scale)
    bite_cx = left + int(18 * scale)
    bite_cy = top + int(38 * scale)
    draw.ellipse(
        [bite_cx - bite_r, bite_cy - bite_r, bite_cx + bite_r, bite_cy + bite_r],
        fill=bg,
        outline=bg,
    )
    stem_w = max(2, int(4 * scale))
    stem_h = int(14 * scale)
    draw.rectangle([cx - stem_w // 2, top - stem_h, cx + stem_w // 2, top + int(4 * scale)], fill=STEM)
    leaf_r = int(8 * scale)
    draw.ellipse([cx + int(2 * scale), top - stem_h - leaf_r, cx + leaf_r * 2, top - stem_h + leaf_r], fill=STEM)


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "C:/Windows/Fonts/meiryo.ttc",
        "C:/Windows/Fonts/msgothic.ttc",
        "C:/Windows/Fonts/arial.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size=size, index=1 if bold and path.endswith(".ttc") else 0)
        except OSError:
            continue
    return ImageFont.load_default()


def save_mark_png() -> None:
    size = 512
    bg = (0, 0, 0, 0)
    img = Image.new("RGBA", (size, size), bg)
    draw = ImageDraw.Draw(img)
    draw_bitten_apple_opaque(draw, size // 2, size // 2 + 20, 3.2, bg)
    img.save(OUT / "かじられたリンゴマーク.png", "PNG")


def save_card_front() -> None:
    w, h = 840, 520
    img = Image.new("RGBA", (w, h), CARD_BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([4, 4, w - 4, h - 4], radius=20, outline=CARD_BORDER, width=2)
    f_title = font(52, bold=True)
    f_sub = font(26)
    f_name = font(36)
    draw.text((w // 2, 170), "BadApple", fill=TEXT_MAIN, font=f_title, anchor="mm")
    draw.text((w // 2, 250), "赤霧市一松 1H", fill=TEXT_SUB, font=f_sub, anchor="mm")
    draw.text((w // 2, 295), "20:00 – 24:00", fill=TEXT_SUB, font=f_sub, anchor="mm")
    draw.text((w // 2, 400), "黒 須", fill=TEXT_NAME, font=f_name, anchor="mm")
    img.save(OUT / "黒須の名刺_表面.png", "PNG")


def save_card_back() -> None:
    w, h = 840, 520
    img = Image.new("RGBA", (w, h), CARD_BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([4, 4, w - 4, h - 4], radius=20, outline=CARD_BORDER, width=2)
    draw_bitten_apple_opaque(draw, w // 2, h // 2 + 10, 2.8, CARD_BG)
    img.save(OUT / "黒須の名刺_裏面.png", "PNG")


def save_phone_sticker() -> None:
    w, h = 480, 720
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    phone_color = (32, 32, 36, 255)
    draw.rounded_rectangle([80, 40, w - 80, h - 40], radius=36, fill=phone_color, outline=(60, 60, 68, 255), width=3)
    draw.rounded_rectangle([110, 70, w - 110, h - 70], radius=24, fill=(20, 20, 24, 255))
    # 背面ステッカー領域
    sticker_cx, sticker_cy = w // 2, h // 2 + 40
    sr = 70
    draw.ellipse([sticker_cx - sr, sticker_cy - sr, sticker_cx + sr, sticker_cy + sr], fill=(40, 40, 44, 255))
    draw_bitten_apple_opaque(draw, sticker_cx, sticker_cy, 1.4, (40, 40, 44, 255))
    img.save(OUT / "土井スマホ_背面_かじられたリンゴ.png", "PNG")


if __name__ == "__main__":
    save_mark_png()
    save_card_front()
    save_card_back()
    save_phone_sticker()
    print("Generated PL assets in", OUT)