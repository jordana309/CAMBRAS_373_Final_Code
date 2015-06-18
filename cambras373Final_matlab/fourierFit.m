% fourierFit.m
% Team CAMBRAS - Written by Jordan Argyle
% ME373 Spring 2015
% Final Project
% This function takes the coefficients for a 3rd-order fourier regression fit and returns the value
% at x.

% a0 + a1*cos(x*p)+b1*sin(x*p) + a2*cos(2*x*p)+b2*sin(2*x*p) + a3*cos(3*x*p)+b3*sin(3*x*p), where
  % p=kw, where k is the subscript on a,b (1,2, or 3)
  
function theFit = fourierFit(coefs)
  a0 = coefs(1);
  a1 = coefs(2);
  b1 = coefs(3);
  a2 = coefs(4);
  b2 = coefs(5);
  a3 = coefs(6);
  b3 = coefs(7);
  w  = coefs(8);
  x  = coefs(9);
  %theFit = a0 + a1*cos(w*x)+b1*sin(w*x) + a2*cos(2*w*x)+b2*sin(2*w*x) + a3*cos(3*w*x)+b3*sin(3*w*x);
  theFit = a0 + a1*cos(x*w)+b1*sin(x*w) + a2*cos(2*x*w)+b2*sin(2*x*w) + a3*cos(3*x*w)+b3*sin(3*x*w);
end