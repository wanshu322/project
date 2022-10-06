/****************************CSC421 Assignment 2*********************************/
/****************************    Wanshu Wang         ****************************/
/*********************Find the closest distance of pair of points****************/
#include <iostream> 
#include <float.h> 
#include <stdlib.h> 
#include <math.h> 
#include <fstream>

using namespace std;


struct Point
{
	int x;
	int y;
};

struct DistancePair
{
	double distance; //the closest distance
	Point p1; //the point p1
	Point p2; //the point p2
};

double dist(Point p, Point q)
{
	return sqrt((p.x - q.x)*(p.x - q.x) + (p.y - q.y)*(p.y - q.y));
}


//This function is to find the closest pair of points in set P[n] by using Brute Force meethod
DistancePair findMin(Point P[], int n)
{
	double min = DBL_MAX;
	DistancePair pair;
	for (int i = 0; i < n; i++)
	{
		for (int j = i + 1; j < n; j++)
			if (dist(P[i], P[j]) < min)
			{
				min = dist(P[i], P[j]);
				pair.p1 = P[i];
				pair.p2 = P[j];
			}
		
	}
	pair.distance = min;
	 
	return pair;
}


//find the minimum of two values
double min(double x, double y)
{
	return (x < y) ? x : y;
}


DistancePair stripP(Point strip[], int length, double d)
{
	double min = d;
	DistancePair pair;
	pair.distance = d;
	for (int i = 0; i < length; i++)
	{
		for (int j = i + 1; j < length && (strip[j].y - strip[i].y); j++)
			if (dist(strip[i], strip[j]) < pair.distance)
			{
				pair.distance = dist(strip[i], strip[j]);
				pair.p1 = strip[i];
				pair.p2 = strip[j];

			}

	}

	return pair;
}




//recursive function
//Px[] includes all the points sorted by x-coordinate
//Py[] includes all the points sorted by y-coordinate
DistancePair closestP(Point Px[], Point Py[], int n)
{
	double Min;
	int mid = n / 2;
	Point midPoint;
	midPoint.x = Px[mid].x;
	midPoint.y = Px[mid].y;


	Point* PyL = new Point[mid+1];
	Point* PyR = new Point[n-mid-1];
	//If P has less than three points, use brute force method
	if (n <= 3)
	{

		delete[] PyL;
		delete[] PyR;
		return findMin(Px, n);
	}
		 

	//Find the point in the middle
	

	int iL = 0, iR = 0;
	for (int i = 0; i < n; i++)
	{
		if (Py[i].x <= midPoint.x)
			PyL[iL++] = Py[i];
		else
			PyR[iR++] = Py[i];

	}


	DistancePair dL = closestP(Px, PyL, mid);
	DistancePair dR = closestP(Px + mid, PyR, n - mid);

	DistancePair pair;
	pair.distance = min(dL.distance, dR.distance);
	if (dL.distance < dR.distance)
	{
		pair = dL;
	}
	else
		pair = dR;


	Point* strip = new Point[n];
	int* index = new int[n];
	int j = 0;
	
	for (int i=0; i<n; i++)
	{
		if (abs(Py[i].x - midPoint.x) < pair.distance)
		{
			strip[j] = Py[i], j++;
				
			
		}
	
	}

	
	//if the closest pair of points are in the strip.
	DistancePair stripPair = stripP(strip, j, pair.distance);
	//pair.distance = min(pair.distance, stripPair.distance);
	if (pair.distance > stripPair.distance)
	{
		pair = stripPair;
		
	}
	
	



	delete[] strip;
	
	return pair;
}


// Needed to sort array of points according to X coordinate 
int compareX(const void* a, const void* b)
{
	Point *p1 = (Point *)a, *p2 = (Point *)b;
	return (p1->x - p2->x);
}
// Needed to sort array of points according to Y coordinate 
int compareY(const void* a, const void* b)
{
	Point *p1 = (Point *)a, *p2 = (Point *)b;
	return (p1->y - p2->y);
}

DistancePair closest(Point P[], int n)
{
	//allocate the array
	Point* Px = new Point[n];
	Point* Py = new Point[n];

	
	for (int i = 0; i < n; i++)
	{
		Px[i] = P[i];
		Py[i] = P[i];
	}

	qsort(Px, n, sizeof(Point), compareX);
	qsort(Py, n, sizeof(Point), compareY);


	
	// Use recursive function closestUtil() to find the smallest distance 
	DistancePair pair;
	pair = closestP(Px, Py, n);

	delete[] Px;
	delete[] Py;



	return pair;
}




// Driver program to test above functions 
int main()
{


	Point P1[10000];
	ifstream inFile;

	//test file"10points.txt"
	inFile.open("10points.txt");
	if (!inFile)
	{
		cout << "Unable to open file";
		system("pause");
		exit(1);
	}
	
	int i = 0;
	while (inFile >> P1[i].x >> P1[i].y)
	{
		
		inFile >> P1[i+1].x>>P1[i+1].y;
		//cout << "(" << P1[i].x << "," << P1[i].y << ")";
		//cout << "(" << P1[i+1].x << "," << P1[i+1].y << ")";
		i++;
		i++;
	
	}
	inFile.close();

	Point* P= new Point[i];
	for (int j = 0; j < i; j++)
	{
		P[j]=P1[j];
		//cout << "(" << P[j].x << "," << P[j].y << ")";
		
	}
	
	

	int n = i;
	DistancePair pair1 = closest(P, n);
	cout << "10 points test file: " <<endl;
	cout << "The smallest distance is:  "<< pair1.distance << endl;
	cout <<"The points are:(" << pair1.p1.x<< "," << pair1.p1.y
		<< ") <---> (" << pair1.p2.x << "," << pair1.p2.y << ")\n"<<endl;
	//system("pause");

	delete[] P;



	//test file"100points.txt"
	inFile.open("100points.txt");
	if (!inFile)
	{
		cout << "Unable to open file";
		system("pause");
		exit(1);
	}

	i = 0;
	while (inFile >> P1[i].x >> P1[i].y)
	{

		inFile >> P1[i + 1].x >> P1[i + 1].y;
		//cout << "(" << P1[i].x << "," << P1[i].y << ")";
		//cout << "(" << P1[i+1].x << "," << P1[i+1].y << ")";
		i++;
		i++;

	}
	inFile.close();

	Point* P2 = new Point[i];
	for (int j = 0; j < i; j++)
	{
		P2[j] = P1[j];
		//cout << "(" << P[j].x << "," << P[j].y << ")";

	}
	//system("pause");


	n = i;
	DistancePair pair2 = closest(P2, n);
	cout << "100 points test file: " << endl;
	cout << "The smallest distance is:  " << pair2.distance << endl;
	cout << "The points are:(" << pair2.p1.x << "," << pair2.p1.y
		<< ") <---> (" << pair2.p2.x << "," << pair2.p2.y << ")\n" << endl;
	//system("pause");

	

	delete[] P2;



	//test file"1000points.txt"
	inFile.open("1000points.txt");
	if (!inFile)
	{
		cout << "Unable to open file";
		system("pause");
		exit(1);
	}

	i = 0;
	while (inFile >> P1[i].x >> P1[i].y)
	{

		inFile >> P1[i + 1].x >> P1[i + 1].y;
		//cout << "(" << P1[i].x << "," << P1[i].y << ")";
		//cout << "(" << P1[i+1].x << "," << P1[i+1].y << ")";
		i++;
		i++;

	}
	inFile.close();

	Point* P3 = new Point[i];
	for (int j = 0; j < i; j++)
	{
		P3[j] = P1[j];
		//cout << "(" << P[j].x << "," << P[j].y << ")";

	}
	//system("pause");


	n = i;
	DistancePair pair3 = closest(P3, n);
	cout << "1000 points test file: " << endl;
	cout << "The smallest distance is:  " << pair3.distance << endl;
	cout << "The points are:(" << pair3.p1.x << "," << pair3.p1.y
		<< ") <---> (" << pair3.p2.x << "," << pair3.p2.y << ")" << endl;

	system("pause");

	delete[] P3;
	return 0;
}

