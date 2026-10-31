"""Convert the original monochrome XP CUR, preserving its Windows AND mask."""
from pathlib import Path
import struct
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
source = ROOT / 'assets/xp/cursors/arrow.cur'
data = source.read_bytes()
reserved, kind, count = struct.unpack_from('<HHH', data)
assert (reserved, kind, count) == (0, 2, 1), 'Expected one Windows cursor'
offset = struct.unpack_from('<I', data, 18)[0]
header_size, width, combined_height, planes, bits = struct.unpack_from('<IiiHH', data, offset)
assert bits == 1 and planes == 1 and combined_height > 0, 'Expected a bottom-up monochrome cursor'
height = combined_height // 2
stride = ((width + 31) // 32) * 4
palette = [struct.unpack_from('<BBBB', data, offset + header_size + index * 4) for index in range(2)]
xor_start = offset + header_size + 8
and_start = xor_start + stride * height
assert and_start + stride * height <= len(data), 'Missing transparency mask'
image = Image.new('RGBA', (width, height), (0, 0, 0, 0))
for y in range(height):
    row = (height - 1 - y) * stride
    for x in range(width):
        bit = 7 - x % 8
        color_index = (data[xor_start + row + x // 8] >> bit) & 1
        masked = (data[and_start + row + x // 8] >> bit) & 1
        # This arrow has no invert-screen pixels; reject unsupported cursors.
        assert not (masked and color_index), 'Invert-screen cursor pixels are unsupported'
        blue, green, red, _ = palette[color_index]
        image.putpixel((x, y), (red, green, blue, 0 if masked else 255))
image.save(source.with_suffix('.png'))
image.save(source.with_name('arrow-rgba.png'))
assert image.getpixel((width - 1, height - 1))[3] == 0
print('PASS: RGBA cursor generated with the original transparency mask')
