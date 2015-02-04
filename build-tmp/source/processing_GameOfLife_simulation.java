import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class processing_GameOfLife_simulation extends PApplet {

//import java.lang.Object;
//import java.lang.Math;
  
//instead of #defines in the C code
short X_AXIS_LEN = 32; //length of x axis
short Y_AXIS_LEN = 8; //length of y axis


byte[] fb = new byte[X_AXIS_LEN];      /* framebuffer */
//byte fb[];
byte[] state_storage = new byte[X_AXIS_LEN]; //area to store pixel states

byte LOW_DIFF_THRESHOLD = 42 ;//threshold of how many generations can pass
                                //with a low difference betweem each other
                                //before reset.
short MED_DIFF_THRESHOLD = 196; //same as above but for medium difference.

byte update_gen_flag = 0;

//framebuffer functions
//void clear_fb();
//void push_fb();

//stuff for game of life things
//void get_new_states();
//byte get_new_pixel_state(byte in_states[], short x, short y);
//byte get_current_pixel_state(byte in[], short x,short y); 
//byte get_difference(byte a[],byte b[]);

//variables to store various difference counts
byte low_diff_count=0;
byte old_low_diff_count=0;
short med_diff_count=0;
short old_med_diff_count=0;



//void fb_to_rect_grid(int x_begin, int y_begin, byte in_fb[], color on_color, color off_color); 
//void push_byte_to_grid(short x_row, byte x_byte);

short generation_count=0;

//void init_button();
//void reset_grid();

public void init_size(){
        //size(256,64);
        //size(512,128);
        
        //makes the size using X_AXIS_LEN*16 and Y_AXIS_LEN*16, 
        //(left shift by 4 multiplies by 16, 2^4 = 16),
        //example:
        //(1<<4) = 16 = 0b00010000, (8<<4) = 8*16 = 128 = 0b10000000;
        size((X_AXIS_LEN<<4),(Y_AXIS_LEN<<4)); 
}

public void delay(int delay_time)
{
  int time = millis();
  while(millis() - time <= delay_time);
}

public void setup(){
    
    init_size();
    reset_grid(); 
    background(51);
}


public void draw(){
     
  
    //while(true){
        println("Generation Count: " + generation_count);
        //print(generation_count);
        //print("\n\r");
        
        //increment the generation count
        generation_count++;
        //push framebuffer to the display
        push_fb();
        //get the new states and add them to the framebuffer,
        //or reset the display if there isn't enough action
        get_new_states();
        
        //println(generation_count);
        
        delay(500);
        
    //}
    
}

public void fb_to_rect_grid(int x_begin, int y_begin, byte in_fb[], int on_color, int off_color){
    //sends a framebuffer to a grid of rectangles
    for(int x_cor=x_begin;x_cor<X_AXIS_LEN;x_cor++){
        for(int y_cor=y_begin;y_cor<Y_AXIS_LEN;y_cor++){
            if((byte)((in_fb[x_cor]) & (byte)(1<<(y_cor)))!=0){
            //if the bit in in_fb is set the turn on part of grid 
                fill(on_color);
                //fill(0);
                rect((x_cor<<4),(y_cor<<4),(1<<4),(1<<4));  
                //set(x_cor,y_cor,pixel_color_black);
                //set(x_cor,y_cor,#FFF967);
            } else {
                fill(off_color);
                //fill(255);
                rect((x_cor<<4),(y_cor<<4),(1<<4),(1<<4));
                //set(x_cor,y_cor,pixel_color_white);
                // set(x_cor,y_cor,#01fffd);
            }
        }
    }
}
public void fb_to_ellipse_grid(int x_begin, int y_begin, byte in_fb[], int on_color, int off_color){
    //sends a framebuffer to a grid of ellipses
    for(int x_cor=x_begin;x_cor<X_AXIS_LEN;x_cor++){
        for(int y_cor=y_begin;y_cor<Y_AXIS_LEN;y_cor++){
            if((byte)((in_fb[x_cor]) & (byte)(1<<(y_cor)))!=0){
            //if the bit in in_fb is set the turn on part of grid 
                ellipseMode(CORNER);
                fill(on_color);
                //fill(0);
                ellipse((x_cor<<4),(y_cor<<4),(1<<4),(1<<4));  
            } else {
                ellipseMode(CORNER);
                fill(off_color);
                //fill(255);
                ellipse((x_cor<<4),(y_cor<<4),(1<<4),(1<<4));
            }
        }
    }
}

/*
void push_byte_to_grid(short x_row, byte x_byte){
    
    color pixel_color_black = ((0x00<<16)|(0x00<<8)|(0x00<<0));
    color pixel_color_white = ((0xFF<<16)|(0xFF<<8)|(0xFF<<0));
    
}*/


public void clear_fb(){
//clears the framebuffer
    short count;
    for(count=0;count<X_AXIS_LEN;count++){
        fb[count]=0;
    }
}

public void push_fb(){
//pushes frambuffer into the virtual display
    int pixel_color_black = ((0xFF<<24)|(0x00<<16)|(0x00<<8)|(0x00<<0));
    int pixel_color_white = ((0xFF<<24)|(0xFF<<16)|(0xFF<<8)|(0xFF<<0));
    
    //color set_color = #ccff66;
    int set_color = 0xff66ff66; //color to use for set (on) bits int the bitmap
    //color clear_color = #dddddd;
    int clear_color = 0xff8e8e8e; //color to use for cleared (off) bits in bitmap
    
    fb_to_ellipse_grid(0,0,fb,set_color,clear_color); //send the framebuffer to the grid
}


public void reset_grid(){
//resets the framebuffer with "random" values
    int tempint;
    byte k;
    for(k=0;k<X_AXIS_LEN;k++){
        
        //tempint = (int)((Math.random())*255); //use if in Java Mode
        tempint = (int)random(0,255); //use in Java or JavaScript Mode (default Processing)
         
        //fb[k]=0x00;
        fb[k] = (byte)(tempint & 0xff); 
        //fb[k] = (byte)random(0,255);
    }
    generation_count=0;
}

public byte get_current_pixel_state(byte[] in_byte, short x,short y){
//get the state (1==alive,0==dead), of a particular pixel/cell and return it

    //for wrapping the display axis so the 
    //Game of Life doesn't seem as restricted
    //this is called a toroidal array
    if(x < 0){ x = (short)(X_AXIS_LEN - 1);}//else{x=0;}
    if(x == X_AXIS_LEN) {x = 0;}
    if(y < 0){ y = (short)(Y_AXIS_LEN - 1);}//else{y=0;}
    if(y == Y_AXIS_LEN) {y = 0;}
    
    //return the value of the bit/pixel in question
    return (byte)(in_byte[x] & (1<<y));
}


public byte get_new_pixel_state(byte in_states[], short x,short y){
    
    byte n=0;//to store the neighbor count
    byte state_out=0;
    
    //check on neighbors, see how many are alive.
    if(get_current_pixel_state(in_states, (short)(x-1),y)!=0){n++;}
    if(get_current_pixel_state(in_states, (short)(x-1),(short)(y+1))!=0){n++;}
    if(get_current_pixel_state(in_states, (short)(x-1),(short)(y-1))!=0){n++;}
    
    if(get_current_pixel_state(in_states, x,(short)(y-1))!=0){n++;}
    if(get_current_pixel_state(in_states, x,(short)(y+1))!=0){n++;}
    
    if(get_current_pixel_state(in_states, (short)(x+1),y)!=0){n++;}
    if(get_current_pixel_state(in_states, (short)(x+1),(short)(y+1))!=0){n++;}
    if(get_current_pixel_state(in_states, (short)(x+1),(short)(y-1))!=0){n++;}
    
    //now determine if dead or alive by neighbors,
    //these are implementing the rule's of Conway's Game of Life:
    /* from Wikipedia
     * Any live cell with fewer than two live neighbours dies, as if caused by under-population.
     * Any live cell with two or three live neighbours lives on to the next generation.
     * Any live cell with more than three live neighbours dies, as if by overcrowding.
     * Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
     */
    if((n<2)){state_out=0;}
    else if ((n<=3) && (get_current_pixel_state(in_states, x, y)!=0)){state_out=1;}
    else if ((n==3)){state_out=1;}
    else if ((n>3)){state_out=0;}
    
    return state_out;
}

public void get_new_states(){
//find all the new states and put them in the buffer
    
    //copy the next generation values into state_storage.
    for(short x=0;x<X_AXIS_LEN;x++){  
        for(short y=0;y<Y_AXIS_LEN;y++){
            if(get_new_pixel_state(fb, x, y)!=0){
                state_storage[x] |= (1<<y);
            } else {
                state_storage[x] &= ~(1<<y);
            }
        }
    }
    //store the difference between the two generations in diff_val
    //to be used in finding when to reset when not enough action going on.
    byte diff_val= get_difference(state_storage,fb);
    
    if((diff_val <= 4)){
        //if diff_val is a low difference then increment it's counter
        low_diff_count++;
    }
    else if((diff_val<=8)){
        //if diff_val is a medium difference then increment that counter
        med_diff_count++;
    }
    else{
        //if neither, then decrement their counters to stay longer before reset
        if(low_diff_count > 0){
            low_diff_count--;
        }
        if(med_diff_count >0){
            med_diff_count--;
        }
    }
    
    
    if(low_diff_count > LOW_DIFF_THRESHOLD){
    //if low_diff_count is above threshold, reset
        low_diff_count=0;
        reset_grid();
    }
    else if(med_diff_count > MED_DIFF_THRESHOLD){
    //if med_diff_count is above threshold, reset
        med_diff_count=0;
        reset_grid();
    }
    else{
    //if it is interesting enough so far then just add the new generation
    //to the framebuffer.
        for(short x=0;x<X_AXIS_LEN;x++){
            //put the new values into the framebuffer
            fb[x] = state_storage[x];
        }
    }
}

public byte get_difference(byte[] a,byte[] b){
//gets the amount of differences between two generations
    
    byte x_v,y_v,diff=0;//local variables for things
    for(x_v=0; x_v < X_AXIS_LEN; x_v++){
        for(y_v=0; y_v < Y_AXIS_LEN; y_v++){
            //if changed from 0 to 1 or vise-versa, then increment the difference value
            if(( (get_current_pixel_state(a,x_v,y_v)!=0) && (get_current_pixel_state(b,x_v,y_v) == 0)) 
            || ((get_current_pixel_state(a,x_v,y_v)==0) && (get_current_pixel_state(b,x_v,y_v)!=0)))
            {
                diff++;
            }
        }
    }
    return diff; //return the difference value
}

/*
* SEVEN SEGMENT VIRTUAL DISPLAY CODE
* will be made later, maybe.
* It will have code for a virtual 7 segment display to be used to show
* the generation count, like on the original hardware version.
*/

//bytes to store 7 segment values for numbers 0-9 plus 'E' for error case
byte[] number_seg_bytes = {
//                     unconfigured
//              ABCDEFG^
(byte)0xFD,//0b11111101,//0
(byte)0x60,//0b01100000,//1
(byte)0xDB,//0b11011011,//2
(byte)0xF3,//0b11110011,//3
(byte)0x66,//0b01100110,//4
(byte)0xB7,//0b10110111,//5
(byte)0xDF,//0b10111111,//6
(byte)0xE1,//0b11100001,//7
(byte)0xFF,//0b11111111,//8
(byte)0xE7,//0b11100111,//9
(byte)0x9F,//0b10011111, //'E' for error
};



  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "processing_GameOfLife_simulation" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
