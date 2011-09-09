#ifndef VECTOR_H
# define VECTOR_H

class Vector
{
 public:
 float x;
 float y;
 float z;

 inline Vector(): x(0), y(0), z(0)
 {}

 inline float norm() const
 {
   return sqrt(x*x + y*y + z*z);
 }

 inline void mult(float c)
 {
   x *= c;
   y *= c;
   z *= c;
 }

 inline void normalize()
 {
   mult(1.0f / norm());
 }
};


#endif
