/***************      CSC421 2018 Fall    *******
****************Student Name:  Wanshu Wang********
****************Graham Algorithm - Convex Hull****
***********************2018.10*********************/

#include<iostream>
#include<algorithm>
#include<stack>
using namespace std;


struct Point
{
	int x;
	int y;
};

Point p0;

int direction(Point p, Point q, Point r)
{
	int val = (r.y - p.y)*(q.x - p.x) - (q.y - p.y)*(r.x - p.x);
	if (val == 0) return 0; //0-> colinear
	return (val > 0) ? 2 : 1; //clockwise return 1; counterclockwise return 2;
}


//
int distSq(Point p, Point q)
{
	return (p.x - q.x)*(p.x - q.x) + (p.y - q.y)*(p.y - q.y);
}

// This function used by qsort() to sort an array of 
// points with respect to the first point 
int compare(const void *vp1, const void *vp2)
{
	Point *p1 = (Point *)vp1;
	Point *p2 = (Point *)vp2;

	// Find direction 
	int d = direction(p0, *p1, *p2);
	if (d == 0)
		return (distSq(p0, *p2) >= distSq(p0, *p1)) ? -1 : 1;// p2>p1 , return -1;

	return (d == 2) ? -1 : 1;// d=2 -> cc , p1 < p2 return -1;
}


//This function to find the point which is next to top in the stack
Point nextToTop(stack<Point> &S)
{
	Point p = S.top();
	S.pop();
	Point temp = S.top();
	S.push(p);
	return temp;
}



//Graham Algorithm to get the S array which contains the points of the convex hull
void convexHullGraham(Point points[], int n)//
{
	//find the the point with minumum y-coordinate
	//or the leftmost such point in case of a tie
	int ymin = points[0].y, min = 0;
	for (int i = 1; i < n; i++)
	{
		int y = points[i].y;
		if ((y < ymin) | (ymin == y && points[i].x < points[min].x))
			ymin = points[i].y, min = i;
	}

	//let p0 be the point with minumum y-coordinate 
	Point temp = points[0];
	points[0] = points[min];
	points[min] = temp;
	p0 = points[0];


	//sort the (n-1) rest points by polar angle in counterclockwise order around p0
	qsort(&points[1], n - 1, sizeof(Point), compare);

	//(if more than one point has the same angle, 
	//remove all but the one that is farthest from p0)
	//
	int m = 1;//m is the number of points in the sorted array
	for (int i = 1; i < n;i++)
	{
		//remove point[i] when the angles of point[i+1] and point[i] are same
		while (i < n - 1 && direction(p0, points[i], points[i + 1]) == 0)
			i++;
		points[m] = points[i];
		m++;
	}

	//if the number of points in the new array is less than 2, the convex hull doesn't exist. 
	if (m < 2)
		return;

	else if (m == 2)
	{
		stack<Point> S;
		
		S.push(points[1]);
		S.push(points[0]);

		// print stack S which contains the output points
		while (!S.empty())
		{
			Point p = S.top();
			cout << "(" << p.x << ", " << p.y << ")" << endl;
			S.pop();
		}
		
	}


	//push the first three points in a stack
	else
	{
		stack<Point> S;
		S.push(points[0]);
		S.push(points[1]);
		S.push(points[2]);

		//
		for (int i = 3; i < m; i++)
		{
			// Keep removing top while the angle formed by 
			// points next-to-top, top, and points[i] makes 
			// a non-left turn 
			while ( direction(nextToTop(S), S.top(), points[i]) != 2 )
				S.pop();
			S.push(points[i]);
		}


		// print stack S which contains the output points
	    /*cout << "(" << p0.x << ", " << p0.y << ")" << endl;
		while (!S.empty() && S.size() >1)
		{
			Point p = S.top();
			cout << "(" << p.x << ", " << p.y << ")" << endl;
			S.pop();
		}*/


		// print stack S to Sout which contains the output points
		stack<Point> Sout;
		while (!S.empty() )
		{
			
			Sout.push(S.top());
			S.pop();
		}
		while (!Sout.empty())
		{
			Point p = Sout.top();
			cout << "(" << p.x << ", " << p.y << ")" << endl;
			Sout.pop();
		}
	}

}



// Driver program to test above functions 
int main()
{



	//test case 1
	Point case1[] = { {1,1},{2,2},{3,3} };
	int n1 = sizeof(case1) / sizeof(case1[0]);
	cout << "case1" << endl;
	convexHullGraham(case1, n1);


	//test case 2
	Point case2[] = { {5,4},{6,2},{4,1} };
	int n2 = sizeof(case2) / sizeof(case2[0]);
	cout << "case2" << endl;
	convexHullGraham(case2, n2);

	//test case 3
	Point case3[] = { {0,5},{-1,3},{2,4},{0,0},{-1,-1},{2,0},{1,-2} };
	int n3 = sizeof(case3) / sizeof(case3[0]);
	cout << "case3" << endl;
	convexHullGraham(case3, n3);

	//test case 4
	Point case4[] = { {5,4},{6,2},{4,3},{3,1},{3,6},{1,2},{2,3} };
	int n4 = sizeof(case4) / sizeof(case4[0]);
	cout << "case4" << endl;
	convexHullGraham(case4, n4);

	//test case 5
	Point case5[] = { {1,3},{3,1}, {5,4},{2,6}, {10,12},{6,2}, {7,5},{4,1}, {8,2},{12,1}, {14,5},{3,12}, {13,5},{17,2}, {1,6},{3,7},{2,9},{5,8} };
	int n5 = sizeof(case5) / sizeof(case5[0]);
	cout << "case5" << endl;
	convexHullGraham(case5, n5);

	//test case 6
	Point case6[] = { {10,18},{5,1}, {5,11},{12,6}, {10,2},{6,21}, {7,15},{14,1}, {8,2},{1,13}, {4,5},{3,12}, {3,5},{17,12}, {1,16},{13,7},{2,9},{7,8} };
	int n6 = sizeof(case6) / sizeof(case6[0]);
	cout << "case6" << endl;
	convexHullGraham(case6, n6);

	
	
	system("pause");

	return 0;
}


