"""Build brushes/mod_palisade.brush + gfx/mod_palisade.png for the held Palisade.

Copies the vanilla camp_18_03 sprite into a small atlas and writes a one-sprite
brush whose vertex rectangle is moved down by SHIFT_DOWN, so the palisade is
drawn lower on the character (portraits ignore sprite offsets).

Brush layout (reverse engineered from object_1.brush and MSU's msu_world.brush):
  header: magic u32, version u16, atlas path (u16 len + bytes), atlas W u16, H u16,
          12 flag bytes, sprite count u32, 6 bytes
  sprite: id u64 (sdbm hash of the name: h = h * 65599 + c), name (u16 len + bytes), 8 const bytes, w u32, h u32,
          misc block, source path (u16 len + bytes), UV u0 u1 v0 v1 (f32),
          rect left right bottom top (f32), 3 zero bytes
"""
import struct, sys, os
from PIL import Image

vanilla_dir, out_root = sys.argv[1], sys.argv[2]
SRC_NAME = b'camp_18_03'
NEW_NAME = b'mod_palisade_held'
ATLAS_PATH = b'gfx/mod_palisade.png'
SOURCE_PATH = b'mod_palisade\\held.png'
SHIFT_DOWN = float(sys.argv[3]) if len(sys.argv) > 3 else 55.0

d = open(os.path.join(vanilla_dir, 'brushes', 'object_1.brush'), 'rb').read()

# --- header ---
pos = 4 + 2
plen = struct.unpack_from('<H', d, pos)[0]
pos += 2 + plen
atlas_w, atlas_h = struct.unpack_from('<HH', d, pos)
pos += 4
flags = d[pos:pos + 12]; pos += 12
count = struct.unpack_from('<I', d, pos)[0]; pos += 4
tail6 = d[pos:pos + 6]; pos += 6
assert count == 172, count

# --- find the source sprite ---
i = d.find(struct.pack('<H', len(SRC_NAME)) + SRC_NAME)
assert i > 0
p = i + 2 + len(SRC_NAME)
const8 = d[p:p + 8]; p += 8
w, h = struct.unpack_from('<II', d, p); p += 8
# misc block runs up to the source path length; find the path
path_marker = b'combat_objects\\Bandit Camp\\camp_18_03.png'
j = d.find(path_marker, p)
misc = d[p:j - 2]
p = j + len(path_marker)
u0, u1, v0, v1, left, right, bottom, top = struct.unpack_from('<8f', d, p)
print('source', w, h, 'misc', len(misc), 'uv', u0, u1, v0, v1, 'rect', left, right, bottom, top)

# --- atlas ---
atlas = Image.open(os.path.join(vanilla_dir, 'gfx', 'object_1.png')).convert('RGBA')
assert atlas.size == (atlas_w, atlas_h), atlas.size
x0, x1 = round(u0 * atlas_w), round(u1 * atlas_w)
y0, y1 = round(v0 * atlas_h), round(v1 * atlas_h)
region = atlas.crop((x0, y0, x1, y1))
AW, AH = 256, 128
out_atlas = Image.new('RGBA', (AW, AH), (0, 0, 0, 0))
out_atlas.paste(region, (0, 0))
os.makedirs(os.path.join(out_root, 'gfx'), exist_ok=True)
out_atlas.save(os.path.join(out_root, 'gfx', 'mod_palisade.png'))
print('region', (x0, y0, x1, y1), region.size)

nu0, nu1 = 0.0, region.width / AW
nv0, nv1 = 0.0, region.height / AH

# --- write brush ---
def name_hash(b):
    # The game looks sprites up by this hash, it must match the name
    h = 0
    for c in b:
        h = (h * 65599 + c) & 0xFFFFFFFFFFFFFFFF
    return h

def pstr(b):
    return struct.pack('<H', len(b)) + b

out = bytearray()
out += d[0:6]                      # magic + version
out += pstr(ATLAS_PATH)
out += struct.pack('<HH', AW, AH)
out += flags
out += struct.pack('<I', 1)
out += tail6
out += struct.pack('<Q', name_hash(NEW_NAME))
out += pstr(NEW_NAME)
out += const8
out += struct.pack('<II', w, h)
out += misc
out += pstr(SOURCE_PATH)
out += struct.pack('<8f', nu0, nu1, nv0, nv1, left, right, bottom - SHIFT_DOWN, top - SHIFT_DOWN)
out += b'\x00\x00\x00'
os.makedirs(os.path.join(out_root, 'brushes'), exist_ok=True)
open(os.path.join(out_root, 'brushes', 'mod_palisade.brush'), 'wb').write(out)
print('brush', len(out), 'bytes, rect', left, right, bottom - SHIFT_DOWN, top - SHIFT_DOWN)
