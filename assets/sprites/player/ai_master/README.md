# Shadow Blade AI rig source

Generated on 2026-07-30 from the supplied standing-pose and dual-dagger
references. The generated master and sheets use one consistent character
design:

- `shadow_blade_master_v1.png`: transparent full-character proportion guide.
- `shadow_blade_upper_parts_v1.png`: transparent upper-body source sheet.
- `shadow_blade_lower_parts_v1.png`: transparent lower-body and weapon sheet.

Runtime-ready cutouts live in:

`res://assets/sprites/player/shadow_blade_ai_parts/v1/`

The runtime scene fits cutouts to named target bounds and assigns draw order by
part id. Replacing a PNG with the same filename keeps the rig interface stable.

Generation constraints:

- preserve silver front hair, dark rear hair, black cat ears, golden eyes;
- preserve black scarf, dark leather armor, bronze hardware and twin daggers;
- both feet share one ground line;
- arms and legs remain separated for shoulder, elbow, wrist, hip, knee and
  ankle animation;
- no floor shadow, labels, text, extra limbs or extra weapons.
