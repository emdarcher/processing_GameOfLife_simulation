//import java.lang.Object;
//import java.lang.Math;
//public class GameOfLife_sim_edit extends PApplet{

    //static public void main(String args[]) {
    //   PApplet.main(new String[] { "GameOfLife_sim_edit2" });
   // }

  
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

void init_size(){
        //size(256,64);
        size(300,80);
}

void delay(int delay)
{
  int time = millis();
  while(millis() - time <= delay);
}

void setup(){
    
    init_size();
    reset_grid(); 
    background(51);
}


void draw(){
     
  
    //while(true){
        
        println(generation_count);
        
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

void fb_to_rect_grid(int x_begin, int y_begin, byte in_fb[], color on_color, color off_color){
    
    //for(int y_cor=y_begin;y_cor<Y_AXIS_LEN;y_cor++){
            for(int x_cor=x_begin;x_cor<X_AXIS_LEN;x_cor++){
            for(int y_cor=y_begin;y_cor<Y_AXIS_LEN;y_cor++){
                    if((byte)((in_fb[x_cor]) & (byte)(1<<(y_cor)))!=0){
                            //fill(on_color);
                            fill(0);
                            rect((x_cor<<3),(y_cor<<3),(1<<3),(1<<3));  
                            //set(x_cor,y_cor,pixel_color_black);
                            //set(x_cor,y_cor,#FFF967);
                    } else {
                            //fill(off_color);
                            fill(255);
                            rect((x_cor<<3),(y_cor<<3),(1<<3),(1<<3));
                            //set(x_cor,y_cor,pixel_color_white);
                            // set(x_cor,y_cor,#01fffd);
                    }
            }
    }
}
void fb_to_ellipse_grid(int x_begin, int y_begin, byte in_fb[], color on_color, color off_color){
    
    //for(int y_cor=y_begin;y_cor<Y_AXIS_LEN;y_cor++){
            for(int x_cor=x_begin;x_cor<X_AXIS_LEN;x_cor++){
            for(int y_cor=y_begin;y_cor<Y_AXIS_LEN;y_cor++){
                    if((byte)((in_fb[x_cor]) & (byte)(1<<(y_cor)))!=0){
                            
                            ellipseMode(CORNER);
                            fill(on_color);
                            //fill(0);
                            ellipse((x_cor<<3),(y_cor<<3),(1<<3),(1<<3));  
                            //set(x_cor,y_cor,pixel_color_black);
                            //set(x_cor,y_cor,#FFF967);
                    } else {
                            ellipseMode(CORNER);
                            fill(off_color);
                            //fill(255);
                            ellipse((x_cor<<3),(y_cor<<3),(1<<3),(1<<3));
                            //set(x_cor,y_cor,pixel_color_white);
                            // set(x_cor,y_cor,#01fffd);
                    }
            }
    }
}

/*
void push_byte_to_grid(short x_row, byte x_byte){
    
    color pixel_color_black = ((0x00<<16)|(0x00<<8)|(0x00<<0));
    color pixel_color_white = ((0xFF<<16)|(0xFF<<8)|(0xFF<<0));
    
}*/


void clear_fb(){
//clears the framebuffer
    short count;
    for(count=0;count<X_AXIS_LEN;count++){
        fb[count]=0;
    }
}

void push_fb(){
//pushes frambuffer into the ht1632c chip in the display
    color pixel_color_black = ((0xFF<<24)|(0x00<<16)|(0x00<<8)|(0x00<<0));
    color pixel_color_white = ((0xFF<<24)|(0xFF<<16)|(0xFF<<8)|(0xFF<<0));
    
    //color set_color = #ccff66;
    color set_color = #66ff66;
    //color clear_color = #dddddd;
    color clear_color = #8e8e8e;
    //fb_to_rect_grid(0,0,fb,pixel_color_black,pixel_color_white);
    //fb_to_ellipse_grid(0,0,fb,pixel_color_black,pixel_color_white);
    fb_to_ellipse_grid(0,0,fb,set_color,clear_color);
    //char i=X_AXIS_LEN;
    //while(i--)
    //{
    //    //ht1632c_data8((i*2),fb[i]);
    //    
    //}
}


void reset_grid(){
//resets the framebuffer with "random" values
    int tempint;
    byte k;
    for(k=0;k<X_AXIS_LEN;k++){
        
        tempint = (int)((Math.random())*255);
        //tempint = (int)random(0,255);
         
        //fb[k]=0x00;
        fb[k] = (byte)(tempint & 0xff); 
        //fb[k] = (byte)random(0,255);
        
        //fb[k] = ((byte)((Math.random())*((byte)255)) & (byte)0xff);
    }
    generation_count=0;
}

byte get_current_pixel_state(byte[] in, short x,short y){
//get the state (1==alive,0==dead), of a particular pixel/cell and return it

    //for wrapping the display axis so the 
    //Game of Life doesn't seem as restricted
    //this is called a toroidal array
    if(x < 0){ x = (short)(X_AXIS_LEN - 1);}//else{x=0;}
    if(x == X_AXIS_LEN) {x = 0;}
    if(y < 0){ y = (short)(Y_AXIS_LEN - 1);}//else{y=0;}
    if(y == Y_AXIS_LEN) {y = 0;}
    
    //return the value
    return (byte)(in[x] & (1<<y));
}


byte get_new_pixel_state(byte in_states[], short x,short y){
    
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

void get_new_states(){
//find all the new states and put them in the buffer
    
    //copy the current stuff into storage
    
    //short x=X_AXIS_LEN;
    //while(x > 0){
    for(short x=0;x<X_AXIS_LEN;x++){  
        //short y=Y_AXIS_LEN;
        //while(y-- > 0){
        for(short y=0;y<Y_AXIS_LEN;y++){
            if(get_new_pixel_state(fb, x, y)!=0){
                state_storage[x] |= (1<<y);
            } else {
                state_storage[x] &= ~(1<<y);
            }
            //y--;
        }
        //x--;
    }
    //store the difference between the two generations in diff_val
    //to be used in finding when to reset.
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
    /*
    #if DO_YOU_WANT_BUTTON_INT0==0
    //if you don't want to use INT0 for button
    //then this "if" statement will compile
    //which just checks the button pin's state whenever
    //this function runs
    if(bit_is_clear(BUTTON_PIN, BUTTON_BIT)){
        reset_grid();
    } 
    else 
    #endif*/
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

byte get_difference(byte[] a,byte[] b)
{//gets the amount of differences between two generations
    byte x_v,y_v,diff=0;

    for(x_v=0; x_v < X_AXIS_LEN; x_v++)
    {
        for(y_v=0; y_v < Y_AXIS_LEN; y_v++)
        {
            //if changed from 0 to 1 or vise-versa, then increment the difference value
            if(( (get_current_pixel_state(a,x_v,y_v)!=0) && (get_current_pixel_state(b,x_v,y_v) == 0)) 
            || ((get_current_pixel_state(a,x_v,y_v)==0) && (get_current_pixel_state(b,x_v,y_v)!=0)))
            {
                diff++;
            }
        }
    }
    return diff;
}
/*
void display_byte_bitmap_rectPixels( byte inBMP[], int bmp_charlen, int x_begin, int y_begin ){
                                //RGB
        color pixel_color_black = ((0x00<<16)|(0x00<<8)|(0x00<<0));
        color pixel_color_white = ((0xFF<<16)|(0xFF<<8)|(0xFF<<0));
          
                for(int y_cor=y_begin;y_cor<((bmp_charlen));y_cor++){
                        for(int x_cor=x_begin;x_cor<8;x_cor++){
                                if(((byte)(inBMP[y_cor]) & ((1<<7) >> x_cor))>0){
                                        fill(0);
                                        rect((x_cor<<3),(y_cor<<3),(1<<3),(1<<3));  
                                        //set(x_cor,y_cor,pixel_color_black);
                                        //set(x_cor,y_cor,#FFF967);
                                } else {
                                        fill(255);
                                        rect((x_cor<<3),(y_cor<<3),(1<<3),(1<<3));
                                        //set(x_cor,y_cor,pixel_color_white);
                                        // set(x_cor,y_cor,#01fffd);
                                }
                        }
                }
}*/

//}

/********SEVEN SEGMENT VIRTUAL DISPLAY CODE**************/

byte[] number_seg_bytes = {
//       unconfigured
//ABCDEFG^
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



