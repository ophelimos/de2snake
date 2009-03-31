/* Header Files */


/* Defined parameters */
#define LEFT 1
#define RIGHT 2
#define UP 3
#define DOWN 4
#define MAX_FOOD 500
#define SCORE_LENGTH 100
#define MAX_X 1000
#define MAX_Y 1000
#define SCREEN_X 160
#define SCREEN_Y 120
#define BORDER_WIDTH 15
#define GROWTH_RATE 5

 /* Colour codes:
 
 Black = 0
 Blue = 1
 Green = 2
 Light blue = 3
 Red = 4
 Pink = 5
 Yellow = 6 
 White = 7
 */

#define BLACK 0
#define BLUE 1
#define GREEN 2
#define LIGHT_BLUE 3
#define RED 4
#define PINK 5
#define YELLOW 6
#define WHITE 7

#define BKGND_COL 0
#define SNAKE_COL 6
#define FOOD_COL 4
#define BORDER_COL 7

/* Game Data */

int score; //Keeps the count of game score
int gamedelay; //Lower the game delay faster is the game speed.

typedef struct Snake_Data {

int length;
int head_x; // Stores Head X Coordinate
int head_y; // Stores Head Y Coordinate
int head_dir; // Stores Head Direction
int tail_x; // Stores Tail X Coordinat
int tail_y; // Stores Tail Y Coordinat
int tail_dir; // Stores Tail Direction
int bend_x [MAX_X]; //Stores X Bend Coordinate Declare it big enough to accomodate maximum bends
int bend_y [MAX_Y];
int bend_dir [MAX_X]; // Stores Bend direction when tail reaches that X Coordinate
} Snake_Data;

/* Declare a global Snake_Data structure */
Snake_Data Snake;

/* Global keyboard interrupt flag */
int KEYBOARD_INT = 0;

/* Global timer interrupt flag */
int TIMER_INT = 0;

/* Timer parameters */
#define TIMER0_ADDR 0xff1020
#define TIMER1_ADDR 0xff1040

#define MOVE_PERIOD 0x1312d00 /* 5 moves/sec */ /* 0x5F5E100 */ /* 100 000 000 */

/* Functions we need to write */

/* Written using RNG */
int randomvalue (int starting, int ending); // Return a random int value between end and starting parameters

/* Written using VGA adapter */
int get_pixel (int x, int y);
int put_pixel (int x, int y, int color);
void init_vga();

/* Written using keyboard adapter */
int getch();
int init_keyboard();

/* Written using timer */
void init_timer(int address, int period);

/* Functions that really should be moved to a header file */
void game_over();

void gamephysics ()
{
 static int foodcount = 0;//Keep Count of food
 int futurex, futurey, futurepixel;
 int i;
 char scorestring [100];
 //Adds a food if no food is present and up to MAX_FOOD, 20% of the time
 if (foodcount < MAX_FOOD && randomvalue(0,10) < 2) 
  {
    int valid = 0;
    int foodx;
    int foody;
    while (!valid)
     {
          foodx = randomvalue (BORDER_WIDTH,SCREEN_X - BORDER_WIDTH);
          foody = randomvalue (BORDER_WIDTH,SCREEN_Y - BORDER_WIDTH);
	  int tmp = get_pixel (foodx,foody);
          if (tmp != SNAKE_COL && tmp != FOOD_COL)
            {
              put_pixel (foodx,foody,FOOD_COL);
              foodcount++;            
              valid = 1;           
            }
                        
     }          
  } 
  //Boundary Collision Check -
  
  if (Snake.head_x <= BORDER_WIDTH || Snake.head_x >= SCREEN_X - BORDER_WIDTH 
		  || Snake.head_y <= BORDER_WIDTH || Snake.head_y >= SCREEN_Y - BORDER_WIDTH )
    {
        /* TODO: write text on screen */
        /* outtextxy (499,345, "Game Over");     */
        /* delay (3000); */
     game_over(1);
    }
 
  //Get future value of head in int variable futurex and futurey and calculate the logic
  
  futurex = Snake.head_x;
  futurey = Snake.head_y;
  
  if (Snake.head_dir == LEFT)
   {
       futurex --;               
   }
  if (Snake.head_dir == RIGHT)  
   {
      futurex ++;                
   }
  if (Snake.head_dir == UP)  
   {
       futurey --;
   }
  if (Snake.head_dir == DOWN)  
   {
       futurey ++;               
   }  

   futurepixel = get_pixel(futurex,futurey);
   
   if (futurepixel == FOOD_COL)//Food Eaten
    {
       foodcount --; //Reduce count
       score++; //Increase Score
       /* setcolor (0);//Rewrite Score 
        setfillstyle (0,0); 
       bar (11,701,1007, 735);
       setcolor (4); */
/*       sprintf (scorestring, "Score : %d", score); */
       /* outtextxy (20,710, scorestring); */
      //Increase the size of snake by GROWTH_RATE
      if (Snake.tail_dir == UP)
       {
        for (i = 0; i<101;i++)
        {
            put_pixel (Snake.tail_x,Snake.tail_y+i,SNAKE_COL);
        }
         Snake.tail_y += GROWTH_RATE;
       }
      if (Snake.tail_dir == DOWN)
       {
        for (i = 0; i<101;i++) put_pixel (Snake.tail_x,Snake.tail_y-i,SNAKE_COL);                  
        Snake.tail_y -=100;
               
       }       
      if (Snake.tail_dir == LEFT)
       {
        for (i = 0; i<101;i++)
         put_pixel (Snake.tail_x+i,Snake.tail_y,SNAKE_COL);                  
         Snake.tail_x +=100;
       
       }
      if (Snake.tail_dir == RIGHT)
       {
        for (i = 0; i<101;i++)
        put_pixel (Snake.tail_x-i,Snake.tail_y,SNAKE_COL);                  
        Snake.tail_x -=100;
       
       } 
         
    }
   if (futurepixel == SNAKE_COL)
     {
         /* TODO: */
/*     outtextxy (499,345, "Game Over");     
       delay (3000); */
     game_over(1);
    }

}    
     
     
     
void userinput () //Process User Input and maps it into game
{
     int input = getch();
     /* Based on scancode 2 values
        U ARROW E0,75
        L ARROW E0,6B
        D ARROW E0,72
        R ARROW E0,74 
     */
     if (input != 0)
     {
       
       //Change Respective Return value to our MACRO Direction Code Value 
       
       if (input == 0x72) input = DOWN;
       
       else if (input == 0x75) input = UP;
       
       else if (input == 0x6B) input = LEFT;
       
       else if (input == 0x74) input = RIGHT;

       else return;
       
       //Change head direction based on logic

       static int i = 0;
       if ( i > 1000) i = 0; // Makes the bend array a circular queue
      
       if (input == LEFT && Snake.head_dir != RIGHT && Snake.head_dir != LEFT)
        {
          Snake.head_dir = LEFT;    
          Snake.bend_x [i] = Snake.head_x;
          Snake.bend_y [i] = Snake.head_y;
          Snake.bend_dir [i] = LEFT;
          i++;
        }    
       if (input == RIGHT && Snake.head_dir != LEFT && Snake.head_dir != RIGHT)
        {
          Snake.head_dir = RIGHT;
          Snake.bend_x [i] = Snake.head_x;
          Snake.bend_y [i] = Snake.head_y;
          Snake.bend_dir [i] = RIGHT;
          i++;        
        }
       if (input == UP && Snake.head_dir != DOWN && Snake.head_dir != UP)
        {
          Snake.head_dir = UP;
          Snake.bend_x [i] = Snake.head_x;
          Snake.bend_y [i] = Snake.head_y;
          Snake.bend_dir [i] = UP;
           i++;        
        }
       if (input == DOWN && Snake.head_dir != UP && Snake.head_dir != DOWN)
        {
          Snake.head_dir = DOWN;       
          Snake.bend_x [i] = Snake.head_x;
          Snake.bend_y [i] = Snake.head_y;
          Snake.bend_dir [i] = DOWN;
          i++;        
        }     
     }

     static int j = 0;
       if ( j > 1000) j = 0;
 
 //Code to change the y direction at respective time
  if (Snake.tail_x == Snake.bend_x [j] && Snake.tail_y == Snake.bend_y [j])
   {
      Snake.tail_dir = Snake.bend_dir [j];
      j++;                
   }
  
}

void movesnake ()
{
   //Move the Head
   if (Snake.head_dir == LEFT)
   {
       Snake.head_x --;               
   }
   if (Snake.head_dir == RIGHT)  
   {
      Snake.head_x ++;                
   }
   if (Snake.head_dir == UP)  
   {
       Snake.head_y --;
   }
   if (Snake.head_dir == DOWN)  
   {
       Snake.head_y ++;               
                      
   }  
   put_pixel (Snake.head_x, Snake.head_y, SNAKE_COL);

//Move the Tail
   put_pixel (Snake.tail_x, Snake.tail_y, BKGND_COL);
   if (Snake.tail_dir == LEFT)
   {
       Snake.tail_x --;               
   }
   if (Snake.tail_dir == RIGHT)  
   {
      Snake.tail_x ++;                
   }
   if (Snake.tail_dir == UP)  
   {
       Snake.tail_y --;
   }
   if (Snake.tail_dir == DOWN)  
   {
       Snake.tail_y ++;               
                      
   }  
  

}
    
void gameengine ()//Soul of our game.
{
  while (1)     
     {
         if (TIMER_INT != 0)
         {
             TIMER_INT = 0;
             movesnake ();
	     gamephysics ();    
         }
         if (KEYBOARD_INT != 0)
         {
             /* A key's been pressed */
             userinput ();
         }
     }

}

void initscreen ( ) //Draws Initial Screen.
{
     int i;
     char scorestring [100];
     //Write Score on screen
/*     sprintf (scorestring, "Score : %d", score); */
     /* TODO: Score/text writing function */
     /* outtextxy (20,710, scorestring); */
     //Draw Intial Snake Body
     for (i = Snake.length; i>0;i--) //This part should be redesigned for change of code of initial values   
     {
      put_pixel (Snake.head_x-i,Snake.head_y,SNAKE_COL);     
     }
 }

void initgamedata ( ) //Snakes starting coordinate if you modify any one make sure also modify dependent values
{
  int i;
  Snake.length = 10;
  Snake.head_x = 20;
  Snake.head_y = 20;
  Snake.head_dir = RIGHT;
  Snake.tail_x = Snake.head_x - Snake.length;
  Snake.tail_y = Snake.head_y;
  Snake.tail_dir = Snake.head_dir;
  for (i = 0; i <1000;i++) // There is no bend initally
   {
        Snake.bend_x[i] = 0;
        Snake.bend_dir[i] = 0; 
   }
  score = 0;
}

void game_over(int code)
{
	int i, j;
	for (i = 0; i < SCREEN_X; i++)
	{
		for (j = 0; j < SCREEN_Y; j++)
		{
			put_pixel (i, j, RED);
		}
	}
	exit(code);
}

// Main Function

int main ()
{
 int error = init_keyboard();
 init_vga();
 initgamedata ();
 initscreen ();
 init_timer(TIMER0_ADDR, MOVE_PERIOD);
 gameengine (); 
 return 0;
}
