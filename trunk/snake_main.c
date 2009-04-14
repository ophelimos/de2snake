/* Original C code pulled from
 * http://www.cprogrammingreference.com/Tutorials/Games_Programming/Snake.php,
 * and then extensively modified for integration with the DE2. */

/* Original code license:
   You have permission to copy this game
   executable and source code and modify it, Improve it, anything you
   want.

   You can even publish this content on your website, we just ask you
   to pop us a mail and place a small link to us if you find this
   stuff worthy enough to be a part of your website!!!
*/

/* Header Files */

/* Wav file */
#include "harppluck.h"

/* Defined parameters */
#define LEFT 1
#define RIGHT 2
#define UP 3
#define DOWN 4
#define MAX_FOOD 500
#define SCORE_LENGTH 100
#define SCREEN_X 160
#define SCREEN_Y 120
#define BORDER_WIDTH 5
#define GROWTH_RATE 10
#define MAX_BENDS 1000

/* Snake parameters */
#define SNAKE_LENGTH 20
#define START_X 80
#define START_Y 60
#define START_DIR RIGHT

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
#define BORDER_COL 1

/* Game Data */

int score; //Keeps the count of game score
int gamedelay; //Lower the game delay faster is the game speed.
int head_bend = 0;
int tail_bend = 0;

typedef struct Snake_Data {

    int length;
    int head_x; // Stores Head X Coordinate
    int head_y; // Stores Head Y Coordinate
    int head_dir; // Stores Head Direction
    int tail_x; // Stores Tail X Coordinat
    int tail_y; // Stores Tail Y Coordinat
    int tail_dir; // Stores Tail Direction
    int bend_x [MAX_BENDS]; //Stores X Bend Coordinate Declare it big enough to accomodate maximum bends
    int bend_y [MAX_BENDS];
    int bend_dir [MAX_BENDS]; // Stores Bend direction when tail reaches that X Coordinate
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

#define MOVE_PERIOD 0x5f5e10 /* 16 moves/sec */
/*0x1312d00*/ /* = 5 moves/sec */
/* 0x5F5E100 */ /* 100 000 000 = 1 move/sec */

/* Functions we need to write */

/* Written using RNG */
int randomvalue (int starting, int ending); // Return a random int value between ending and starting parameters

/* Written using VGA adapter */
int get_pixel (int x, int y);
int put_pixel (int x, int y, int color);
void init_vga(int color);
void draw_border(int start_x, int end_x, int start_y, int end_y, int color);

/* Written using keyboard adapter */
int getch();
int init_keyboard();

/* Written using timer */
void init_timer(int address, int period);

/* Written using the audio CODEC */
int playwav(int *wavfile);

/* Written using LCD screen */
void game_over(int code);
void print_lcd(char *string);

/* Using pushbuttons */
void init_pushbuttons();

/* Global pointer to the current location of the audio file we're playing */
int *audio_cur;
int *audio_end;
int *audio_channels; /* num_channels -1 */

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
            if (tmp == BKGND_COL)
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
        /* Play a sound */
        playwav(harppluck);
        foodcount --; //Reduce count
        score++; //Increase Score
        sprintf (scorestring, "Score : %d", score);
        print_lcd(scorestring);
        //Increase the size of snake by GROWTH_RATE
        if (Snake.tail_dir == UP)
        {
            for (i = 0; i < GROWTH_RATE; i++)
            {
                put_pixel (Snake.tail_x, Snake.tail_y+i, SNAKE_COL);
            }
            Snake.tail_y += GROWTH_RATE;
        }
        if (Snake.tail_dir == DOWN)
        {
            for (i = 0; i < GROWTH_RATE;i++)
            {
                put_pixel (Snake.tail_x, Snake.tail_y-i, SNAKE_COL);
            }
            Snake.tail_y -= GROWTH_RATE;
               
        }       
        if (Snake.tail_dir == LEFT)
        {
            for (i = 0; i < GROWTH_RATE; i++)
            {
                put_pixel (Snake.tail_x+i, Snake.tail_y, SNAKE_COL);
            }
            Snake.tail_x += GROWTH_RATE;
        }
        if (Snake.tail_dir == RIGHT)
        {
            for (i = 0; i < GROWTH_RATE; i++)
            {
                put_pixel (Snake.tail_x-i, Snake.tail_y, SNAKE_COL);
            }
            Snake.tail_x -= GROWTH_RATE;
        } 
         
    }
    if (futurepixel == SNAKE_COL)
    {
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
      
        if (input == LEFT && Snake.head_dir != RIGHT && Snake.head_dir != LEFT)
        {
            Snake.head_dir = LEFT;    
            Snake.bend_x [head_bend] = Snake.head_x;
            Snake.bend_y [head_bend] = Snake.head_y;
            Snake.bend_dir [head_bend] = LEFT;
            head_bend++;
            if ( head_bend > MAX_BENDS) head_bend = 0; // Makes the bend array a circular queue
        }    
        if (input == RIGHT && Snake.head_dir != LEFT && Snake.head_dir != RIGHT)
        {
            Snake.head_dir = RIGHT;
            Snake.bend_x [head_bend] = Snake.head_x;
            Snake.bend_y [head_bend] = Snake.head_y;
            Snake.bend_dir [head_bend] = RIGHT;
            head_bend++;
            if ( head_bend > MAX_BENDS) head_bend = 0; // Makes the bend array a circular queue
        }
        if (input == UP && Snake.head_dir != DOWN && Snake.head_dir != UP)
        {
            Snake.head_dir = UP;
            Snake.bend_x [head_bend] = Snake.head_x;
            Snake.bend_y [head_bend] = Snake.head_y;
            Snake.bend_dir [head_bend] = UP;
            head_bend++;
            if ( head_bend > MAX_BENDS) head_bend = 0; // Makes the bend array a circular queue
        }
        if (input == DOWN && Snake.head_dir != UP && Snake.head_dir != DOWN)
        {
            Snake.head_dir = DOWN;       
            Snake.bend_x [head_bend] = Snake.head_x;
            Snake.bend_y [head_bend] = Snake.head_y;
            Snake.bend_dir [head_bend] = DOWN;
            head_bend++;
            if ( head_bend > MAX_BENDS) head_bend = 0; // Makes the bend array a circular queue
        }     
    }
}

void movesnake ()
{
    // Bend the tail
    if (Snake.tail_x == Snake.bend_x [tail_bend] && Snake.tail_y == Snake.bend_y [tail_bend])
    {
        Snake.tail_dir = Snake.bend_dir [tail_bend];
        tail_bend++;
        if ( tail_bend > MAX_BENDS) tail_bend = 0;
    }

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
    char scorestring [100];
    //Write Score on LCD
    sprintf (scorestring, "Score : %d", score);
    print_lcd(scorestring);
    //Draw Initial Snake Body
    int i;
    for (i = 0; i <= Snake.length; i++)
    {
        put_pixel (Snake.head_x-i, Snake.head_y, SNAKE_COL);     
    }
    /* Draw some borders */
    /* left */
    draw_border(0, BORDER_WIDTH, 0, SCREEN_Y, BORDER_COL);
    /* top */
    draw_border(0, SCREEN_X, 0, BORDER_WIDTH, BORDER_COL);
    /* right */
    draw_border(SCREEN_X-BORDER_WIDTH, SCREEN_X, 0, SCREEN_Y, BORDER_COL);
    /* bottom */
    draw_border(0, SCREEN_X, SCREEN_Y-BORDER_WIDTH, SCREEN_Y, BORDER_COL);

    /* Draw a random border somewhere (as an obstacle) */
    int x1 = randomvalue(BORDER_WIDTH, SCREEN_X-BORDER_WIDTH);
    int x2 = randomvalue(x1, SCREEN_X-BORDER_WIDTH);
    int y1 = randomvalue(BORDER_WIDTH, SCREEN_Y-BORDER_WIDTH);
    int y2 = randomvalue(y1, SCREEN_Y-BORDER_WIDTH);
    draw_border(x1, x2, y1, y2);
}

void initgamedata ( ) //Snakes starting coordinate if you modify any one make sure also modify dependent values
{
    Snake.length = SNAKE_LENGTH;
    Snake.head_x = START_X;
    Snake.head_y = START_Y;
    Snake.head_dir = RIGHT;
    Snake.tail_x = Snake.head_x - Snake.length;
    Snake.tail_y = Snake.head_y;
    Snake.tail_dir = Snake.head_dir;
    int i;
    for (i = 0; i < MAX_BENDS; i++) // There is no bend initally
    {
        Snake.bend_x[i] = 0;
        Snake.bend_y[i] = 0;
        Snake.bend_dir[i] = 0; 
    }
    score = 0;
}

/*void game_over(int code)
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
*/

// Main Function

int main ()
{
    int error = init_keyboard();
    init_vga(BKGND_COL);
    initgamedata ();
    initscreen ();
    init_timer(TIMER0_ADDR, MOVE_PERIOD);
    gameengine (); 
    return 0;
}
