final int LAST = 32;
final int UNIT = 50;
int buf_count = 0;
int rx_index = 0;

int import_flg = 0;
int start_millis = 0;
int time_stump = 0;
int now_millis = 0;
int length = 1000;

// read
int key_cnt = 0;
String[] csvs1;
String[] csvs2;
String[] csvs3;

int data_cnt = 0;
int timestamp = 0;
int[] d_xyz = {0, 0, 0};
int[] d_cash = {0, 0, 0};

float output_index = 0;

void setup() {
    size(800,800,P3D);
    background(255);
    fill(0);
    noStroke();

    csvs1 = loadStrings("../csv/degs1.csv");
    csvs2 = loadStrings("../csv/degs2.csv");
    csvs3 = loadStrings("../csv/degs3.csv");
}

void draw() {
    background(255);
    import_millis();
    allows(width/2, height/2, 0);
}

//ハロー、関数さんよ。
void import_millis(){
    if(import_flg == 1){
        now_millis = millis();
        if(start_millis == 0){
            start_millis = now_millis;
            csvread();
        }
        if((now_millis-start_millis) >= (timestamp)){
            d_xyz[0] = d_cash[0];
            d_xyz[1] = d_cash[1];
            d_xyz[2] = d_cash[2];
            csvread();
        }
    }else if(import_flg == 0){
        d_xyz[0] = 0;
        d_xyz[1] = 0;
        d_xyz[2] = 0;
        data_cnt = 0;
        start_millis = 0;
    }
}

void csvread(){
    String data_s = "";
    if(key_cnt == 1) data_s = csvs1[data_cnt];
    else if(key_cnt == 2) data_s = csvs2[data_cnt];
    else if(key_cnt == 3) data_s = csvs3[data_cnt];

    String[] data_c = split(data_s,',');
    if(data_c.length == 4){
        timestamp = int(data_c[0]);
        d_cash[0] = int(data_c[1]);
        d_cash[1] = int(data_c[2]);
        d_cash[2] = int(data_c[3]);
        data_cnt++;
    }else {
        import_flg = 0;
    }
}

void allows(int x, int y, int z){
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

void keyPressed(){
    if(49<=key && key<=51){
        if(import_flg == 0){
            key_cnt = key - 48;
            import_flg = 1;
        }
    }else if(key == 'e'){
        import_flg = 0;
    }else if(key == 'q'){
        exit();
    }
}