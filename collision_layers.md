# Collision Layers Documentation

## Layer Assignments
1. Layer 1: Walls/Environment
   - Used for: Walls, obstacles, and environmental elements
   - Collides with: Player and Monsters

2. Layer 2: Player
   - Used for: Player character
   - Collides with: Walls and Monsters
   - Player's attack area only collides with Monsters

3. Layer 3: Items
   - Used for: Collectible items
   - No collision, uses Area2D for overlap detection

4. Layer 4: Monsters
   - Used for: Enemy characters
   - Collides with: Walls and Player

## Collision Matrix
| Layer          | Walls (1) | Player (2) | Items (3) | Monsters (4) |
|----------------|-----------|------------|-----------|--------------|
| Walls (1)      | No        | Yes        | No        | Yes          |
| Player (2)     | Yes       | No         | No        | Yes          |
| Items (3)      | No        | No         | No        | No           |
| Monsters (4)   | Yes       | Yes        | No        | No           |

## Implementation Notes
- Player attack area is on Layer 0 with mask 4 (only detects monsters)
- Items use Area2D with no collision layers, only overlap detection
- All moving entities (Player, Monsters) collide with walls
- Monsters can collide with player for damage 