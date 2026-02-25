# Assignment - Bubble Bobble clone in Godot

This repository was created by Saffron Birch for CSCI 4160U - Interactive Media.

---

## Godot Version

The version used for this assignment is Godot Engine v4.5.1.

---

## How to Run the Program

### Windows
1. In File Explorer, navigate to the project's root directory.
2. Open `exports`.
2. To run the game, open the file, `bubble_bobble_clone_in_godot_saffron_birch.exe`.

### Linux
1. In your terminal, navigate to the project's root directory:
```bash
cd .../bubble_bobble_clone_in_godot_saffron_birch
```

2. Navigate to the `exports` directory:
```bash
cd /exports
```

3. To run the game, enter the command:
```bash
./bubble_bobble_clone_in_godot_saffron_birch.x86_64
```

---

## Controls
- Move Left = `Left` Arrow Key, or `A` Key
- Move Right = `Right` Arrow Key, or `D` Dey
- Jump = `Up` Arrow Key, or `W` Key
- Fire = `Space` Key
- Start = `Space` Key
- Restart = `R` Key

---

## How to Play the Game
Upon running the game, press Space to start. Control your character to trap enemies inside bubbles by shooting them with the Z key. Once an enemy is trapped in a bubble, jump into the bubble to pop it and defeat the enemy. Each defeated enemy awards 1 point. Avoid getting hit by enemies or their projectiles, as you only have 3 lives. The game spawns 5 enemies that patrol platforms and shoot projectiles. Survive as long as possible and achieve the highest score!

---

## What I Implemented
### Scenes
#### Player
The player scene contains:
- A `CharacterBody2D` as the root node for physics-based movement
- An `AnimatedSprite2D` node with multiple animations:
    - `idle` - Standing still animation
    - `runLeft` / `runRight` - Running animations in both directions
    - `blowLeft` / `blowRight` - Bubble-shooting animations in both directions
- A `CollisionShape2D` node to enable collisions with platforms, enemies, and projectiles


Player functionality:
- Gravity-based movement with jumping ability
- Can shoot bubbles in the direction they're facing
- Tracks lives (3 total) and loses a life when hit by enemies or projectiles
- Out-of-bounds detection that resets player position if they fall off screen


#### Enemy
The enemy scene contains:
- A `CharacterBody2D` as the root node with gravity-based movement
- An `AnimatedSprite2D` with animations:
    - `moveLeft` / `moveRight` - Walking animations
    - `shootLeft` / `shootRight` - Projectile shooting animations
- Two `RayCast2D` nodes (RayCastRight and RayCastLeft) for wall detection
- A `CollisionShape2D` for physical collisions
- A `Timer` node for controlling shooting intervals


Enemy AI behavior:
- Patrols platforms by walking back and forth
- Turns around when hitting walls (detected by raycasts)
- Falls off platform edges to reach lower levels
- Shoots projectiles every 2 seconds
- Has two states: `ACTIVE` (normal behavior) and `TRAPPED` (frozen when caught in bubble)
- Stops all physics processing when trapped in a bubble


#### Bubble (Projectile)
The bubble scene contains:
- An `Area2D` as the root node for collision detection
- An `AnimatedSprite2D` with animations:
    - `shootBubble` - Initial shooting animation
    - `movingBubble` - Bubble traveling through air
    - `trappedEnemy` - Bubble containing a trapped enemy
    - `popBubble` - Bubble popping animation
- A `CollisionShape2D` for detecting collisions with enemies and player


Bubble behavior:
- Shoots forward in the direction the player is facing
- Gradually slows down due to deceleration
- Stops after traveling a maximum distance
- Floats upward slowly when empty
- When it collides with an enemy:
    - Traps the enemy inside
    - Changes to trapped animation
    - Floats upward
    - Enemy becomes invisible and frozen
- Can only be popped by the player when it contains a trapped enemy
- Popping a trapped bubble destroys both the bubble and enemy, awarding 1 point
- Empty bubbles pass through the player harmlessly


#### Enemy Projectile
The projectile scene contains:
- An `Area2D` for collision detection
- An `AnimatedSprite2D` with animations:
    - `shootLeft`/`shootRight` - Projectile shooting animations
- A `CollisionShape2D` for detecting hits on the player


Projectile behavior:
- Travels in the direction the enemy is facing
- Removes itself when hitting the player (causing damage)
- Automatically despawns when leaving the screen bounds


#### Level Scene
The level scene contains:
- A `Node` as the root node for containment
- A `TileMapLayer` for the platforms
- Two `StaticBody2D` nodes for the left and right walls. Each wall contains a `CollisionShape2D` as its child, to detect collisions with the player and the enemies
- Platform-based level design allowing enemies to fall between levels


#### Main Scene
The Main Scene contains:
- A background `Sprite2D` node
- UI elements managed through a `CanvasLayer`:
    - Score display using individual digit sprites in an `HBoxContainer`
    - Health display showing 3 heart sprites that disappear as lives are lost
    - Title screen sprite
    - Game over screen sprite
    - Menu prompts using `AnimatedSprite2D`

- Enemy spawning system:
    - Uses a `Timer` node to spawn enemies at 2-second intervals
    - Tracks active enemies in an array
    - Maximum of 5 enemies on screen at once
    - Spawns enemies at random positions at the top of the screen
    - Randomly assigns initial movement direction
    - Filters array to remove freed/destroyed enemies
    - Resumes spawning when enemy count drops below maximum



### Scripts
#### player.gd
Movement system:
- Implements gravity using get_gravity() for realistic falling
- Horizontal movement using arrow keys or WASD
- Jump mechanic with fixed velocity when on floor
- Tracks facing direction (last_direction) for bubble shooting


Animation system:
- Plays appropriate animations based on movement state
- Uses `is_shooting` flag to prevent animation override during bubble shooting
- Shooting animation plays to completion before spawning bubble


Bubble shooting:
- Creates bubble instances from preloaded scene
- Sets bubble direction based on player's facing direction
- Animation sequence: play blow animation → wait for completion → spawn bubble


Life management:
- Tracks player lives (starts with 3)
- lose_life() function is called when hit by enemy projectile
- Out of bounds detection and position reset


#### enemy.gd
AI patrol system:
- Uses raycasts positioned at enemy edges to detect walls
- Reverses direction when raycast collision is detected
- Only checks the raycast in current movement direction to prevent flip-flopping
- Applies gravity and falls off platform edges
- Continues moving at constant speed


State management:
- `ACTIVE` state: Normal patrolling and shooting behavior
- `TRAPPED` state: All physics processing disabled, frozen in place
- bubble_trap() function switches state when caught


Shooting system:
- Timer-based shooting
- Stops movement during shooting animation
- Plays direction-appropriate shooting animation
- Spawns projectile after animation completes


Animation handling:
- Plays movement animations (moveLeft/moveRight) when walking
- Plays shooting animations (shootLeft/shootRight) when attacking
- Uses await animated_sprite.animation_finished to time projectile spawning


#### bubble.gd
Movement phases:
- Initial shooting phase: Plays spawn animation, no movement
- Moving phase: Travels forward with gradual deceleration
- Floating phase: Moves upward slowly when stopped and empty
- Trapping phase: Moves upward while carrying trapped enemy


State flags:
- `is_shooting`: Prevents movement during initial spawn animation
- `is_stopped`: Indicates bubble has stopped moving forward
- `is_trapping`: Indicates bubble contains a trapped enemy
- `is_popping`: Prevents duplicate pop attempts


Collision handling:
- Detects enemy collisions only when not already trapping
- Calls enemy's bubble_trap() to freeze them
- Hides enemy sprite and changes to trapped animation
- Syncs trapped enemy position with bubble each frame
- Detects player collision only when trapping an enemy
- Awards score through main scene when popped by player


Lifecycle:
- Spawns → moves forward → stops → floats up → auto-pops after 2 seconds (if empty)
- OR: Spawns → hits enemy → traps enemy → floats up → waits for player to pop
- Plays pop animation before destroying itself
- Destroys trapped enemy when popped


#### projectile.gd
Movement:
- Travels in straight line at constant speed
- Direction set by spawning enemy


Collision detection:
- Uses `Area2D` to detect player
- Checks if colliding body is in "player" group
- Calls player's lose_life() function on hit
- Self-destructs after hitting player


Cleanup:
- Automatically removes itself when leaving screen bounds
- Prevents memory leaks from off-screen projectiles


#### main.gd
Game state management:
- Implements state machine with `MENU`, `PLAY`, and `GAME_OVER` states
- Handles state transitions and UI visibility
- Manages input for starting game and restarting


Player management:
- Spawns new player instance when starting/restarting game
- Resets player lives and position
- Checks for player validity before accessing
- Handles player out-of-bounds reset


Enemy management:
- Maintains enemies array tracking all active enemies
- Filters array each frame to remove freed enemies
- Manages enemy spawning through timer
- Clears all enemies on game over
- Checks enemy out-of-bounds and resets position


Score system:
- add_score(points) function increments score
- update_score_display() converts score to individual digit sprites
- Creates new `Sprite2D` nodes for each digit
- Uses preloaded digit textures (0-5)
- Displays in `HBoxContainer` for automatic layout


Health display:
- Shows/hides heart sprites based on player lives
- Updates in real-time as player takes damage
- All hearts visible at game start


Timer management:
- Spawns enemies every 2 seconds during PLAY state
- Stops spawning when 5 enemies are active
- Stops timer on game over
- Restarts timer when starting new game

---

### Assets
All of the assets were taken from the `Code The Classics - Cavern` repository.

---

## Repo Structure
```text
bubble_bobble_clone_in_godot_saffron_birch
├─ README.md
├─ README.pdf
├─ .gitignore
├─ project.godot
├─ assets/
| ├─ images/
| | ├─ bg.png
| | ├─ block.png
| | ├─ blow.png
| | ├─ bolt.png
| | ├─ font.png
| | ├─ health.png
| | ├─ orb.png
| | ├─ over.png
| | ├─ pop.png
| | ├─ robot.png
| | ├─ run.png
| | ├─ space.png
| | ├─ still.png
| | ├─ title.png
| | ├─ trap.png
├─ scenes/
| ├─ bubble.tscn
| ├─ enemy.tscn
| ├─ level.tscn
| ├─ main.tscn
| ├─ player.tscn
| ├─ projectile.tscn
├─ scripts
| ├─ bubble.gd
| ├─ enemy.gd
| ├─ main.gd
| ├─ player.gd
| ├─ projectile.gd
├─ exports
| ├─ bubble_bobble_clone_in_godot_saffron_birch.exe
| ├─bubble_bobble_clone_in_godot_saffron_birch.x86_64

```
