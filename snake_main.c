/* Header Files */


/* Macros */
#define LEFT 1
#define RIGHT 2
#define UP 3
#define DOWN 4
#define MAX_FOOD 500
#define SCORE_LENGTH 100
#define MAX_X 1000
#define MAX_Y 1000

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
extern int KEYBOARD_INT;

/* Global timer interrupt flag */
extern int TIMER_INT;

/* Timer parameters */
#define TIMER0_ADDR 0xff1020
#define TIMER1_ADDR 0xff1040

#define MOVE_PERIOD 0x5F5E100 /* 100 000 000 */

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

void gamephysics ()
{
 static int foodcount = 0;//Keep Count of food
 int futurex, futurey, futurepixel;
 int i;
 char scorestring [100];
 if (foodcount < MAX_FOOD) //Adds a food if no food is present and up to MAX_FOOD
  {
    int valid = 0;
    int foodx;
    int foody;
    while (!valid)
     {
          foodx = randomvalue (15,1003);
          foody = randomvalue (15,695);
          if (get_pixel (foodx,foody)!= 15)
            {
              put_pixel (foodx,foody,2);
              foodcount++;            
              valid = 1;           
            }
                        
     }          
  } 
  //Boundary Collision Check -
  
  if (Snake.head_x <= 10 || Snake.head_x >= 1008 || Snake.head_y <= 10 || Snake.head_y >= 700)
    {
        /* TODO: write text on screen */
        /* outtextxy (499,345, "Game Over");     */
        /* delay (3000); */
     exit (1); 
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
   
   if (futurepixel == 2)//Food Eaten
    {
       foodcount --; //Reduce count
       score++; //Increase Score
       /* setcolor (0);//Rewrite Score 
        setfillstyle (0,0); 
       bar (11,701,1007, 735);
       setcolor (4); */
/*       sprintf (scorestring, "Score : %d", score); */
       /* outtextxy (20,710, scorestring); */
      //Increase the size of snake by 100 pixel you can put as much as you want
      if (Snake.tail_dir == UP)
       {
        for (i = 0; i<101;i++) put_pixel (Snake.tail_x,Snake.tail_y+i,15);                  
         Snake.tail_y +=100;
       
       }
      if (Snake.tail_dir == DOWN)
       {
        for (i = 0; i<101;i++) put_pixel (Snake.tail_x,Snake.tail_y-i,15);                  
        Snake.tail_y -=100;
               
       }       
      if (Snake.tail_dir == LEFT)
       {
        for (i = 0; i<101;i++)
         put_pixel (Snake.tail_x+i,Snake.tail_y,15);                  
         Snake.tail_x +=100;
       
       }
      if (Snake.tail_dir == RIGHT)
       {
        for (i = 0; i<101;i++)
        put_pixel (Snake.tail_x-i,Snake.tail_y,15);                  
        Snake.tail_x -=100;
       
       } 
         
    }
   if (futurepixel == 15)
     {
         /* TODO: */
/*     outtextxy (499,345, "Game Over");     
       delay (3000); */
     exit (1); 
    }

}    
     
     
     
void userinput () //Process User Input and maps it into game
{
     static int i = 0;
     if ( i > 1000) i = 0; // Makes the bend array a circular queue
     static int j = 0;
     if ( j > 1000) j = 0;
     char input = getch();
     if (input != 0)
     {
       
       //Change Respective Return value to our MACRO Direction Code Value 
       
       if (input == 80) input = DOWN;
       
       if (input == 72) input = UP;
       
       if (input == 75) input = LEFT;
       
       if (input == 77) input = RIGHT;
       
         
          
       
       //Change head direction based on logic
       
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
   put_pixel (Snake.head_x, Snake.head_y,15);

//Move the Tail
   put_pixel (Snake.tail_x, Snake.tail_y,0);
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
       movesnake ();
       if (KEYBOARD_INT != 0)
       {
           /* A key's been pressed */
           KEYBOARD_INT = 0;
           userinput ();
       }
       gamephysics ();
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
      put_pixel (Snake.head_x-i,Snake.head_y,15);     
     }
 }

void initgamedata ( ) //Snakes starting coordinate if you modify any one make sure also modify dependent values
{
  int i;
  Snake.length = 100;
  Snake.head_x = 200;
  Snake.head_y = 200;
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
