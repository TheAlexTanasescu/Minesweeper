/*
Name: Alex Tanasescu
Course: CPSC 355
Lecture 01 Tutorial 3
Project Part 1
*/

//All the libraries needed
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>

//Global variables that are crucial to the game that can be accessed anywhere
double timeScore, score, timer;
char * name;
int n;

//Created a struct that helps keep track of each values within a score: the    player name, time score and the point score
typedef struct scores
{
  char name[100];
  double regScore, timeScore;
}Score;

/*
Function Name: randomNumber
Inputs: 2 ints: a lower bound and an upper bound and a bool called neg
Output: A double that will be between the two bounds and will be negative if   the bool is true
*/

double randomNumber(int lowerBound, int upperBound, bool neg)
{

  double randomNum = (double)rand()/ RAND_MAX*(upperBound - lowerBound) + lowerBound;
 
  if (neg)
    {
      randomNum *= -1;
    }
  return randomNum;
}

/*
I tried including the math.h library to use the pow function to square numbers but didn't work for some reason so I wrote my own my square function that uses bitwise operations (Please consider this when marking my randomNum)
Function Name: square
Inputs: one int: a number
Output: the number inputted squared
*/
int square(int n)
{
    if (n==0) return 0;

    if (n < 0) n = -n;

    int x = n>>1;

    if (n&1)
        return ((square(x)<<2) + (x<<2) + 1);
    else
        return (square(x)<<2);

}

/*
This function initializes all the bonus signs and surprise packs (!, $, @) in  the table
Function Name: bonusSigns
Inputs: Basically a table of chars, the length the user inputted, a char which represents one of the bonus and an int that represents how many of a bonus sign there are
*/
void bonusSigns(char ** game, int length, char c, int nr)
{
    int randRow, randCol;
    while (nr)
    {
      randRow = randomNumber(0, length, false);
      randCol = randomNumber(0, length, false);

      if (game[randRow][randCol] == '+')
        {
	  nr --;
	  game[randRow][randCol] = c;
        }
    }
}

/*
Initialize the table of x's for the game to start
Function Name: initializeGame
Inputs: A table of doubles that correspond to the floating point values for the points and the length the user inputted
Outputs: A table of chars
*/
char ** initializeGame(double ** table, int length)
{
  int nrNeg = 0;  //A counter for how many bombs there are
  int randRow, randCol;
  int val = 0.2 * square(length);// The limit of how many bombs there are

  //Here I'm just allocating memory for the table of chars
  char ** game = (char **)malloc(sizeof(char *) * length);
  for (int i = 0; i < length; i ++)
    game[i] = (char *)malloc(sizeof(char) * length);
  
  //Populating the table with x's
  for (int i = 0; i < length; i ++)
    for (int j = 0; j < length; j ++){
      table[i][j] = 0;
      game[i][j] = 'X';
    }

  //Checking to see if the negCount is equal to neg Limit in order to stop     placing negative signs  
  while (nrNeg != val)
    {
      randRow = randomNumber(0, length, false);
      randCol = randomNumber(0, length, false);
      
      if (table[randRow][randCol] == 0)
        {
	  nrNeg ++;
	  game[randRow][randCol] = '-';
	  table[randRow][randCol] = randomNumber(0.01, 15.00, true);
        }
    }

  //Starts populating the tbale with positive signs
    for(int i = 0; i < length; i ++)
        for(int j = 0; j < length; j ++)
            if (table[i][j] == 0)
            {
	      table[i][j] = randomNumber(0.01, 15.00, false);
                game[i][j] = '+';
            }

    //Here if the the length is min value of 5 it theres only 1 of each bonus   sign in the table
    if (length == 5)
      {
	bonusSigns(game,length,'!', 1);
	bonusSigns(game,length,'@', 1);
	bonusSigns(game,length,'$', 1);
      }
    
    //If the length is more than 5 then theres roughly 20 percent of each bonus sign in the table
    else
      {
	bonusSigns(game,length,'!', square(length) * 0.2);
	bonusSigns(game,length,'@', square(length) * 0.2);
	bonusSigns(game,length,'$', square(length) * 0.2);	
      }
    return game;
}

/*
This function prints all the chars of a table given the table itself and length
Function Name: displayGame
Inputs: A table of chars and the length
 */
void displayGame(char ** board, int n)
{
    printf("\n");
    for (int i = 0; i < n; i ++)
    {
        for (int j = 0; j < n; j ++)
            printf("%c ", board[i][j]);
        printf("\n");
    }
}

/*
This function calculates the score based on the symbol the user encounters when they enter the coordinates
Function Name: calculateScore
Inputs: Takes in 2 char tables that represent the tables full of x's and the   table full of symbols and table full of doubles that correspond to the floatingpoint values for the points. It also takes the x and y coordinates the user    input
Outputs: The score the user has
*/ 
double calculateScore(double **mat, char **board, char **game, int x, int y )
{
  if (game[x][y] == '$')
    {
      score = (int)score<<1;
      board[x][y] = '$';
    }
  else if(game[x][y] == '!')
    {
      score = (int)score>>1;
      board[x][y] = '!';
    }
  else if(game[x][y] == '@')
    {
      timer += 5;
      board[x][y] = '@';
    }
  else if (game[x][y] == '-')
    {
      score += mat[x][y];
      board[x][y] = '-';
    }
  else
    {
      score += mat[x][y];
      board[x][y] = '+';
    }

  return score;
}

/*
This function prints each players name, time and score to the the logfile as   well as the score file that will be used in the displayTopScores function
Function Name: logScore
Inputs: the name of the player, their time and score;
 */
void logScore(char * name, double timerScore, double regScore)
{
  FILE * filename = fopen("scores.log", "a");
  FILE * scorefile = fopen("topScores.log", "a");
  fprintf(scorefile, "%s %.2f %.2f\n", name, timerScore, regScore);

  fprintf(filename, "\n");
  fprintf(filename, "Player Name: %s\n", name);
  fprintf(filename, "Time: %.2f\n", timerScore);
  fprintf(filename, "Score: %.2f\n", regScore);
  fprintf(filename, "\n");

  fclose(filename);
  fclose(scorefile);

}

/*
This function compares two generic data values, in this case, the score that   were defined in the struct mentioned at the very top
Function Name: compare
Inputs: Two generic data types
Ouputs: An int values that represents the outcome of the comparison of the two in this example we want to check if one socre is less than the other to sort   them in descending order
*/ 
int compare (const void * a, const void * b)
{
  Score *A = (Score *)a;
  Score *B = (Score *)b;

  return (A -> regScore < B -> regScore);
}

/*
This function just lists a number of top scores to the console
Function Name: displayTopScores 
Inputs: an integer that represents how many top scores to display
*/
void displayTopScores(int n)
{
  int lineCount=0;
  FILE * scorefile = fopen("topScores.log", "r"); //r to read the fule
  char line[500];

  //Just checking to see if we hit the end of the file with each line we pass  thru we also increase line count by 1
  while(fgets(line, sizeof(line), scorefile) != NULL)
    lineCount ++;

  //Allocating space for each set of scores
  Score * scores = (Score *)malloc(sizeof(Score) * lineCount);
   lineCount--;

   //Moving the cursor to the beginning 
  fseek(scorefile, 0, SEEK_SET);

  //Scanning each line for input for a string and two floats
  for(int i = 0;fgets(line, sizeof(line), scorefile) != NULL; i ++)
    sscanf(line, "%s %lf %lf",scores[i].name, &(scores[i].timeScore), &(scores[i].regScore));

  //Sorting all the scores using quick sort
  if (lineCount > 1)
    qsort(scores,lineCount, sizeof(Score), compare);

  //Prints all the sets of scores to the console
   for (int i = 0 ; i < ((lineCount < n) ? lineCount : n); i ++)
    printf("Name: %s Time: %.2f Score: %.2f\n", scores[i].name, scores[i].timeScore, scores[i].regScore);
   
   //Closes and the file and frees the memory
   fclose(scorefile);
   free(scores);
}


/*
  This function logs each set of scores and displays n (which is selected by   the user) top scores by calling on
the respective functions
Function Name: exitGame
   */
void exitGame()
{
  
  logScore(name, timeScore, score);
  printf("How many top scores would you like to see? ");
  scanf("%d", &n);
  displayTopScores(n);
  
}


/*
Main driver code that runs the whole program. Returns 0 to signal a clean exit a 1 to signal that something went wrong(invalid input)
*/
int main(int argc, char* argv[])
{
  //Checking for command line arguments and validity
  if (argc != 3)
    {
      printf("Program terminating. Run the program again and enter two command line arguments in addition to the program name\n");
      return 1;
    }

  name = argv[1];
  int length = (atoi(argv[2]));


  if (length < 5 || length > 20)
    {
      printf("Program terminating. Run the program again and enter a number between 5 and 20\n");
      return 1;
    }

  //Greets the user and does initialiazation for firstTurn flag and sets the   visitedCells counter to 0
  printf("Hello, %s\n", name);
  srand(time(NULL));

  int visitedCells = 0;
  bool firstTurn = true;
  int userChoice;

  /*Allocates memory for each of the tables
    First table - The table of floating point values for the points that the   user gets or loses
    Second table - The table that will keep track of if a user visited a cell  or not
    Third table - The table with all the chars representing points and surprise packs(+, -, !, @, $)
  */
  double**mat = (double **)malloc(sizeof(double *) * length);
  for (int i = 0; i < length; i ++)
      mat[i] = (double *)malloc(sizeof(double) * length);

  short ** visited = (short **)malloc(sizeof(short *) * length);
  for (int i = 0; i < length; i ++)
      visited[i] = (short *)malloc(sizeof(short) * length);

  char ** board = (char **)malloc(sizeof(char *) * length);
  for (int i = 0; i < length; i ++)
    board[i] = (char *)malloc(sizeof(char) * length);

  //The main menu, here the player can choose to play the game, quit or see top scores
 playGame:
  printf("Do you want to play the game or see top scores? Enter 1 to play, 2 to see scores or 3 to quit: ");
  scanf("%d", &userChoice);
  if (userChoice == 1)
    {
      char ** game = initializeGame(mat, length);

      for (int i = 0; i < length; i ++)
	for (int j = 0; j < length; j ++)
	  {
	    visited[i][j] = 0;
	    board[i][j] = 'X';
	  }
      int x, y; 
      score = 0.0f;
      double responseTime;
      timer = length * 12; //Setting the timer based on the length
      time_t startTime, endTime;
      //Displays the board to the player so they can choose a cell this repeats until the timer is 0
      displayGame(board, length);
      while (timer > 0)
	{
	  printf("Enter your move (x, y): ");
	  //Calculating response time and time left for the user to play
	  time(&startTime);
	  scanf("%d%d", &x, &y);
	  time(&endTime);      
	  responseTime = difftime(endTime, startTime);
	  timer = timer - responseTime;
	  //If coordinates are less than the 0 than the user quits out of the  game if else continues to next if statement
	  if (x >= 0 && y >= 0)
	    {
	      //Checks to see if coordinates are in range of the board if not  the user gets an error message
	      if (x >= 0 && x < length && y >= 0 && y < length)
		{
		  //Checks to see if the user visistes a  cell before if not   user gets an error message
		  if (visited[x][y] == 0)
		    {
		      visitedCells++;
		      visited[x][y] = 1;
		      calculateScore(mat, board, game, x, y);
		      //Makes sure the user cant lose on the first turn
		      if (firstTurn == true && score <= 0 )
			score = 0;
		      displayGame(board, length);
		      //Checks to see if score is less or equal to 0 and it's  not the first turn
		      if (score <= 0 && firstTurn == false)
			{
			  printf("You lose!\n");
			  exitGame();
			  goto playGame;
			}
		      // Checks to see if all the cells have been visited
		      if (visitedCells == square(length))
			{
			  printf("You won! Nice!\n");
			  exitGame();
			  goto playGame;
			}
		      //Checks to see if time is up
		      if (timer <= 0)
			{
			  printf("You ran out of time!\n");
			  exitGame();
			  goto playGame;
			}
		      firstTurn = false;
		      printf("Total score: %.2f\n", score);
		      printf("Time Left: %.2f\n", timer);
		    }
		  else
		    printf("Already visited (x,y)!\n");
		}
	      else
		printf("Give valid (x, y)! \n");
	    }
	  else
	    {
	      printf("Exiting Game\n");
	      goto playGame;
	    }
	  timeScore = 60.00 - timer;
	}      
    }
  //User can choose to see top scores without playing the game
  else if(userChoice == 2)
    {
      exitGame();
      goto playGame;
      
    }
  //User can quit the program if they want to
  else if (userChoice == 3)
    {
      return 0;
    }
  return 0;
}
