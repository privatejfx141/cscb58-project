# CSCB58 Project: Summer 2017
### Created by:
- Brennan Law
- Jeffrey Li
- Johnson Zhu

## Project Details - Snake
### Project Description:
Our project is a Verilog implementation of the game Snake. Like in the original video game, the player maneuvers a snake which grows in length after eating. The snake is to avoid obstacles such as the game boundaries and itself. If a snake hits an obstacle, the game ends and will need to be restarted.

### Controls used on the FPGA board:
- KEY[0]: Move right
- KEY[1]: Move down
- KEY[2]: Move up
- KEY[3]: Move left
- SW[0]: Reset/start new game
- SW[2], SW[3]: Set game difficulty/speed
- HEX4, HEX5: Display score/apples eaten

### Video URL: TBA

## Motivations
### How does this project relate to the material covered in CSCB58?:
It involves using the VGA display to display the game, a datapath for game mechanics, and a controller to process player input.

### Why is this project interesting/cool (for CSCB58 students, and for non CSCB58 students?):
It's the recreation of a rather complex video game using simple components such as an ALU and a FSM controller.

### Why did you personally choose this project?:
Snake could be easily developed using high-level programming languages such as Python and C#, so it would give us more insight into how the low-level components of the computer work if we coded the game in a hardware description language such as Verilog.

## Attributions
- Game mechanics based off of Pepino's Snake: [Link](https://github.com/Saanlima/Pepino/tree/master/Projects/Snake)
- VGA display based off of "Why Did The Chicken Cross The Road?": [Link](https://github.com/hughdingb58/b58project/blob/master/updated_part2.v)
- For loop code from ASIC World: [Link](http://www.asic-world.com/verilog/verilog_one_day2.html)
