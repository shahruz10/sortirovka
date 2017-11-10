//Selection sort 
int n = 950; 
int[] sort_arr = new int[n]; 

void setup() 
{ 
size(950, 950); 
sort_arr = create_random_array(n, width / 3); 
} 

int[] create_random_array(int n, int max) 
{ 
int[] x = new int[n]; 
for (int i = 0; i < n; i++) 
{ 
x[i] = int(random(max)); 
} 
return x; 
} 

void draw() 
{ 
stroke(0, 0, 169); 
background(250); 
//selection sort 
for (int i=0; i<n-1; i++) 
{ 
int least = i; 
for (int j=i+1; j<n; j++) 
{ 
if(sort_arr[j] < sort_arr[least]) 
{ 
least = j; 
} 
} 
int tmp = sort_arr[i]; 
sort_arr[i] = sort_arr[least]; 
sort_arr[least] = tmp; 
} 
plot_array(sort_arr, n); 
} 

void plot_array(int[] x, int s) 
{ 
stroke(0, 0, 100); 
for (int i = 0; i < s; i++) 
{ 
rect(0, height / s * i, x[i], height / s); 
} 
} 

void mouseClicked() 
{ 
sort_arr = create_random_array(n, width / 2); 
}