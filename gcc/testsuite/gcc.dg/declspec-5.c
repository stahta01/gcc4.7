/* Test declaration specifiers.  Test empty declarations.  Test with
   -pedantic.  */
/* Origin: Joseph Myers <jsm@polyomino.org.uk> */
/* { dg-do compile } */
/* { dg-options "-pedantic" } */

/* If a declaration does not declare a declarator, it must declare a
   tag or the members of an enumeration, and must only contain one
   type specifier.  */

typedef int T;

struct s0;
union u0;
enum e0; /* { dg-warning "warning: ISO C forbids forward references" } */
enum { E0 };
enum e1 { E1 };

/* Not declaring anything (pedwarns).  */
struct { int a; }; /* { dg-warning "warning: unnamed struct/union that defines no instances" } */
int; /* { dg-warning "warning: useless type name in empty declaration" } */
long; /* { dg-warning "warning: useless keyword or type name in empty declaration" } */
/* { dg-warning "warning: empty declaration" "long" { target *-*-* } 22 } */
T; /* { dg-warning "warning: useless type name in empty declaration" } */
static const; /* { dg-warning "warning: useless keyword or type name in empty declaration" } */
/* { dg-warning "warning: empty declaration" "long" { target *-*-* } 25 } */
union { long b; }; /* { dg-warning "warning: unnamed struct/union that defines no instances" } */

/* Multiple type names (errors).  */
struct s1 int; /* { dg-error "error: two or more data types in declaration specifiers" } */
char union u1; /* { dg-error "error: two or more data types in declaration specifiers" } */
/* { dg-warning "warning: useless type name in empty declaration" "char union" { target *-*-* } 31 } */
double enum { E2 }; /* { dg-error "error: two or more data types in declaration specifiers" } */
/* { dg-warning "warning: useless type name in empty declaration" "double enum" { target *-*-* } 33 } */
T struct s2; /* { dg-error "error: two or more data types in declaration specifiers" } */
/* { dg-warning "warning: useless type name in empty declaration" "T struct" { target *-*-* } 35 } */
long union u2; /* { dg-error "error: long, short, signed, unsigned or complex used invalidly in empty declaration" } */
struct s3 short; /* { dg-error "error: long, short, signed, unsigned or complex used invalidly in empty declaration" } */
union u3 signed; /* { dg-error "error: long, short, signed, unsigned or complex used invalidly in empty declaration" } */
unsigned struct s4; /* { dg-error "error: long, short, signed, unsigned or complex used invalidly in empty declaration" } */
_Complex enum { E3 }; /* { dg-error "error: long, short, signed, unsigned or complex used invalidly in empty declaration" } */
