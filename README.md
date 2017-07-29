# CSCB58 Project: Summer 2017

## Project Details
---------------
Project Title: Snake

### Project Description:
	Our project is a Verilog implementation of the game Snake. Like in the original video game, the player maneuvers a snake which grows in length after eating. The snake is to avoid obstacles such as the game boundaries and itself. If a snake hits an obstacle, the game ends and will need to be restarted.

### The controls we will be using on the FPGA board for the game are:
- KEY[0]		Move right
- KEY[1]		Move down
- KEY[2]		Move up
- KEY[3]		Move left
- SW[0]		Reset/start new game
- HEX0, HEX1	Display score/apples eaten
- HEX2, HEX3	Game timer

Video URL: TBA



## Proposal
--------

What do you plan to have completed by the end of the first lab session?:
	Basic movement of the player, random apple generation

What do you plan to have completed by the end of the second lab session?:
	Collision, boundaries, lose condition

What do you plan to have completed by the end of the third lab session?:
	Snake growth, difficulty (speed), aesthetics

What is your backup plan if things don’t work out as planned?
	We will stick to a simplfied version of the game, where it is just a single snake tile eating apples and avoid the boundaries.

What hardware will you need beyond the DE2 board 
(be sure to e-mail Brian if it’s anything beyond the basics to make sure there’s enough to go around)
	We may consider using a joystick for controlling the snake.

## Motivations
-----------
How does this project relate to the material covered in CSCB58?:
	It involves using the VGA display to display the game, a datapath for game mechanics, and a controller to process player input.

Why is this project interesting/cool (for CSCB58 students, and for non CSCB58 students?):
	It's the recreation of a rather complex video game using simple components such as an ALU and a FSM controller.

Why did you personally choose this project?:
	Snake could be easily developed using high-level programming languages such as Python and C#, so it would give us more insight into how the low-level components of the computer work if we coded the game in a hardware description language such as Verilog.

## Attributions
------------
- Game mechanics based off of Pepino's Snake
	https://github.com/Saanlima/Pepino/tree/master/Projects/Snake
- VGA display based off of "Why Did The Chicken Cross The Road?"
	https://github.com/hughdingb58/b58project/blob/master/updated_part2.v
