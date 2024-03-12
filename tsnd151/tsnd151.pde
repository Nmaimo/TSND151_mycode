import processing.serial.*; 
Serial myPort; 

PrintWriter file;

int [] xx13 = {0x9A, 0x13, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00};
int bcc13 = xx13[0]^xx13[1]^xx13[2]^xx13[3]^xx13[4]^xx13[5]^xx13[6]^xx13[7]^xx13[8]^xx13[9]^xx13[10]^xx13[11]^xx13[12]^xx13[13]^xx13[14]^xx13[15];

int[] xx15 = {0x9A, 0x15, 0x00};
int bcc15 = xx15[0]^xx15[1]^xx15[2];

int[] xx55 = {0x9A, 0x55, 0x0A, 0x01, 0x00};
int bcc55 = xx55[0]^xx55[1]^xx55[2]^xx55[3]^xx55[4];

int[] q_wxyz = {0, 0, 0, 0};
int[] d_xyz = {0, 0, 0};

int buf_count = 0;
int rx_index = 0;
int[] rx_data = {0, 0};


int export_flg = 0;
int start_millis = 0;
int timestamp = 0;
int now_millis = 0;

//change here
float bpm = 10.0;
int time_max = 300;

float output_index = 0;


void setup(){
    size(800,800,P3D);
    background(255);
    fill(0);
    noStroke();

// please change serial port.
    myPort = new Serial(this, "COM28", 115200);

    for(int i = 0; i < xx55.length; i++) myPort.write (char(xx55[i]));
    myPort.write (char(bcc55));
    delay(100);

    for(int i = 0; i < xx13.length; i++) myPort.write (char(xx13[i]));
    myPort.write (char(bcc13));
    delay(1000);
}

void serialEvent(Serial myPort) {
    if(true){
        if (myPort.available() > 0) {
            int rx_buf = myPort.read();
            if(buf_count == 0){
                if(rx_buf == 0x9A) buf_count = 1;
                else buf_count = 0;
            }else if(buf_count == 1){
                if(rx_buf == 0x8A) buf_count =2;
                else buf_count = 0;
            }else if((buf_count >= 2)&&(buf_count <= 5)){
                buf_count += 1;
            }else if(buf_count >= 6){
                if(buf_count % 2 == 0){
                    rx_data[0] = rx_buf;
                    rx_index = buf_count/2 - 3;
                }
                else{
                    rx_data[1] = rx_buf;
                    q_wxyz[rx_index] = (rx_data[0]<<0)+(rx_data[1]<<8);
                    if((rx_data[1] & 0x80) == 0x80){
                        q_wxyz[rx_index] = -(((~q_wxyz[rx_index])&0x7FFF)+0x0001);
                    }
                }
                buf_count += 1;
                if(buf_count == 14) buf_count = 0;
            }
        }
    }
}

void draw(){
    background(255);
    allows(width/2, height/2, 0);
    export_millis(time_max);
}

//cal & play
void allows(int x, int y, int z){
    float q_sum = sqrt(sq(q_wxyz[0])+sq(q_wxyz[1])+sq(q_wxyz[2])+sq(q_wxyz[3]));
    float[] q = {q_wxyz[0]/q_sum, q_wxyz[1]/q_sum, q_wxyz[2]/q_sum, q_wxyz[3]/q_sum};
    float[] d = {0.0, 0.0, 0.0};
    d[0] = atan2(2*(q[2]*q[3]+q[1]*q[0]),(sq(q[0])-sq(q[1])-sq(q[2])+sq(q[3]))) * RAD_TO_DEG;
    d[1] = asin(-2*(q[1]*q[3]-q[2]*q[0])) * RAD_TO_DEG;
    d[2] = atan2(2*(q[1]*q[2]+q[3]*q[0]),(sq(q[0])+sq(q[1])-sq(q[2])-sq(q[3]))) * RAD_TO_DEG;
    d_xyz[0] = int(d[0]);
    d_xyz[1] = int(-d[1]);
    d_xyz[2] = int(-d[2]);

    pushMatrix();
    translate(x,y,z);
    rotateZ(radians((d_xyz[2])));
    rotateY(radians((d_xyz[1])));
    rotateX(radians((d_xyz[0])));

    translate(100,0,0);
    fill(255,0,0);
    box(200,10,10);
    translate(-100,-100,0);
    fill(0,255,0);
    box(10,200,10);
    translate(0,100,-100);
    fill(0,0,255);
    box(10,10,200);
    popMatrix();
}

//write process
void export_millis(float stop_min){
    if(export_flg == 1){
        now_millis = millis();
        if(start_millis == 0){
            start_millis = now_millis;
            csvwrite();
        }
        if((now_millis-start_millis) >= (1000.0/bpm*output_index)){
            csvwrite();
        }
        if(now_millis-start_millis >= stop_min*1000){
            file.println(0);
            file.flush();
            file.close();
            exit();
        }
    }else{
        start_millis = 0;
    }
}

//csv write
void csvwrite(){
    timestamp = now_millis - start_millis;
    file.print(timestamp);
    file.print(",");
    file.print(d_xyz[0]);
    file.print(",");
    file.print(d_xyz[1]);
    file.print(",");
    file.println(d_xyz[2]);
    output_index++;
}

//key process
void keyPressed(){
    if(49<=key && key<=51){
        int key_cnt = key - 48;
        file = createWriter("../csv/degs"+key_cnt+".csv");
        export_flg = 1;
    }else if(key == 'q') {
        for(int i = 0; i < xx15.length; i++) myPort.write (char(xx15[i]));
        myPort.write (char(bcc15));
        delay(100);
        
        myPort.clear();
        myPort.stop();

        file.println(0);
        file.flush();
        file.close();

        exit();
    }
}
