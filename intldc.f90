MODULE intldc !Contribution of the branch cuts ("ldc") to the fermionic self-energy
USE vars ! For variables share by all subroutines here and in the dspec module (in particular x0=mu/Delta and xq=q/q_Delta, opp(1:4), location of the angular points of the qp-qp branch cut)
USE dspec
USE modsim
IMPLICIT NONE
REAL(QP) EPSom,EPSu,EPSq
LOGICAL lecture,ecriture,bla0,st
INTEGER profondeur
CHARACTER(len=15) donnees
CHARACTER(len=30) fichierlec1,fichierlec2,fichierlec3
CHARACTER(len=9) donneesq
CHARACTER(len=5) suffixe
REAL(QP) q1,q2,q3,q4
CONTAINS
FUNCTION selfE(k,zk)
 REAL(QP), INTENT(IN) :: k,zk
 COMPLEX(QPC) selfE(1:6)
 COMPLEX(QPC) Iq1(1:6),Iq2(1:6),Iq3(1:6)
 REAL(QP) argq(1:1),e
 LOGICAL err
 CHARACTER(len=250) chainebidon

 temperaturenulle=.TRUE.

 e=0.0_qp


 call system("rm "// "intq"//suffixe//".dat")

 open(20,file="intq"//suffixe//".dat",POSITION="APPEND")
  write(20,*)"!Valeurs de q,intq pour x0,zk,k=",x0,zk,k
 close(20)

! qromovq(f,a,b,dim,arg,varchange,EPS,jmax): Romberg integration of the function f
! with values in R^dim from a to b with precision EPS. arg is a vector of 
! static parameters of the function,
! varchange is a subroutine that performs a change of variable for improper integrals:
! varchange=midpntvq when the function is integrated over a compact interval where it takes finite values
! varchange=midinfvq when b -> +oo (b can be as large as allowed by machine precision) and f decays at least as 1/x^2
! varchange=racinfvq when b -> +oo and f decays as 1/x^(3/2)
! varchange=midsquvq/midsqlvq f has a 1/sqrt(b-x) or 1/sqrt(x-a) (integrable) divergence at the upper/lower bound of the integration interval

 write(6,*)"fichierlec1,fichierlec2:",fichierlec1,fichierlec2
 if(lecture)then
  open(11,file=trim(fichierlec1))
  read(11,*)chainebidon
  write(6,*)chainebidon
  read(*,*)
  open(12,file=trim(fichierlec2))
  read(12,*)chainebidon
  write(6,*)chainebidon
  read(*,*)
!  open(13,file=trim(fichierlec3))
!  read(13,*)
 endif

 if(ecriture)then
  open (16,file=trim(fichierlec1))
  write(16,*)"! grille de valeur de q,om et Mat de qmin=",q1,"à qmax=",q2," avec profondeur=",profondeur
  open (17,file=trim(fichierlec2))
  write(17,*)"! grille de valeur de q,om et Mat de qmin=",q2,"à qmax=",q3," avec profondeur=",profondeur
  open (18,file=trim(fichierlec3))
  write(18,*)"! grille de valeur de q,om et Mat de qmin=",q3,"à qmax=",q4," avec profondeur=",profondeur
 endif

 Iq1(:)=0.0_qp
 Iq2(:)=0.0_qp
 Iq3(:)=0.0_qp

 argq(1)=1.5_qp 
 Iq1=qromovfixed(intq,q1 ,   q2,   6,argq,midpntvcq,EPSq,profondeur,err)
 write(6,*)"Iq1=",Iq1
 write(6,*)"re Iq1=",real(Iq1)
 write(6,*)"im Iq1=",imag(Iq1)
! if(err)  call erreur("q")

 argq(1)=2.5_qp 
 Iq2=qromovfixed(intq,q2,    q3,   6,argq,midpntvcq,EPSq,profondeur,err)
 write(6,*)"re Iq2=",real(Iq2)
 write(6,*)"im Iq2=",imag(Iq2)
 if(err)  call erreur("q")

 argq(1)=3.5_qp 
! Iq3=qromovfixed(intq,q3,    q4,   6,argq,midinfvcq,EPSq,profondeur,err)
 write(6,*)"re Iq3=",real(Iq3)
 write(6,*)"im Iq3=",imag(Iq3)
 if(err)  call erreur("q")

 selfE=2.0_qp*PI*(Iq1+Iq2+Iq3) !Integration sur phi

 open(20,file="intq"//suffixe//".dat",POSITION="APPEND")
  write(20,*)
 close(20)

 close(11)
 close(12)
 close(13)

 close(16)
 close(17)
 close(18)

CONTAINS

 FUNCTION intq(q,argq,m) !Computes size(q) points of the function to be integrate over q
  USE nrutil
  INTEGER,  INTENT(IN) :: m !Always called with m=3: the 3 coefficients of the self-energy matrix
  REAL(QP), INTENT(IN), DIMENSION(:)  ::  q,argq
  COMPLEX(QPC)  intq(size(q),m)

  COMPLEX(QPC), DIMENSION(1:6) ::  I,Ia,Ib,Ic,Id,Ie
  REAL(QP) bmax,qs,fich
  INTEGER is
 
  fich=argq(1)
  intq(:,:)=0.0_qp
 
  do is=1,size(q)
   qs=q(is) !Current value of q, passed on to the intom function in its "arg" argument 
   xq=qs
   call oangpp

   call ecrit(bla0,"qs=",qs)
   call ecrit(bla0,"ptbranchmtpp=",real(ptbranchmtpp,kind=qpc))
   call ecrit(bla0,"opp=",opp)
  
   Ia(:)=0.0_qp
   Ib(:)=0.0_qp
   Ic(:)=0.0_qp
   Id(:)=0.0_qp
   Ie(:)=0.0_qp
   I(:) =0.0_qp
   intq(is,:)=0.0_qp
   
   bmax=1.e6_qp
  
    if(ptbranchmtpp==1)then !BEC-like behavior: integrated from branch cut lower-edge opp(1) to infinity
      Ib=qromovfixed(intom,opp(1)         ,bmax                ,6,(/qs,fich/),racinfvcq,EPSom,profondeur,err) !deals with the 1/om^(3/2) decay at large om
      call ecrit(bla0,'Ib=',Ib)
      if(err)  call erreur("omega")
    elseif(ptbranchmtpp==2)then !One angular point opp(2) besides the lower-edge
      Ib=qromovfixed(intom,opp(1)         ,opp(2)              ,6,(/qs,fich/),midpntvcq,EPSom,profondeur,err) !Integrate from the edge to the angular point
      call ecrit(bla0,'Ib=',Ib)
      if(err)  call erreur("omega")
      Ic=qromovfixed(intom,opp(2)         ,2.0_qp*opp(2)       ,6,(/qs,fich/),midpntvcq,EPSom,profondeur,err) !then from opp(2) to 2*opp(2), this circumscribes the numerical difficulty around opp(2)
      call ecrit(bla0,'Ic=',Ic)
      if(err)  call erreur("omega")
      Id=qromovfixed(intom,2.0_qp*opp(2)  ,bmax                ,6,(/qs,fich/),racinfvcq,EPSom,profondeur,err) !then from 2*opp(2) to infinity
      call ecrit(bla0,'Id=',Id)
      if(err)  call erreur("omega")
    elseif(ptbranchmtpp==3)then !Two angular points opp(2) and opp(3) besides the lower-edge
      Ib=qromovfixed(intom,opp(1)         ,opp(2)              ,6,(/qs,fich/),midpntvcq,EPSom,profondeur,err)
      call ecrit(bla0,'Ib=',Ib)
      if(err)  call erreur("omega")
      Ic=qromovfixed(intom,opp(2)         ,opp(3)              ,6,(/qs,fich/),midpntvcq,EPSom,profondeur,err)
      call ecrit(bla0,'Ic=',Ic)
      if(err)  call erreur("omega")
      Id=qromovfixed(intom,opp(3)         ,2.0_qp*opp(3)       ,6,(/qs,fich/),midpntvcq,EPSom,profondeur,err)
      call ecrit(bla0,'Id=',Id)
      if(err)  call erreur("omega")
      Ie=qromovfixed(intom,2.0_qp*opp(3)  ,bmax                ,6,(/qs,fich/),racinfvcq,EPSom,profondeur,err)
      call ecrit(bla0,'Ie=',Ie)
      if(err)  call erreur("omega")
    else
     STOP "Erreur de ptbranchmntpp"
    endif
  
   I=Ib+Ic+Id+Ie !Combines the integration intervals
   write(6,*)"qs,I=",qs,real(I)

   open(20,file="intq"//suffixe//".dat",POSITION="APPEND")
    write(20,*)qs,real(I(1:3))
   close(20)

   intq(is,:)=I(:)*qs**2 !Jacobian of the q integration
  
  enddo
 END FUNCTION intq

 FUNCTION intom(om,arg,m) !Computes size(om) points of the function  to be integrate over om
  IMPLICIT NONE
  INTEGER,  INTENT(IN) :: m !m=3 here
  REAL(QP), INTENT(IN), DIMENSION(:)  ::  om,arg !arg(1) should be the value of q
  COMPLEX(QPC), DIMENSION(size(om),m)       ::  intom

  COMPLEX(QPC) Gam(1:2,1:2),Mat(1:2,1:2),Mat2(1:2,1:2),MatCat(1:2,1:2),det
  REAL(QP) reM11,reM22,reM12,reM21,imM11,imM22,imM12,imM21,omfi,xqfi
  REAL(QP) q,argintu(1:2),rho(1:2,1:2),ome,enM,enP
  COMPLEX(QPC) IuP(1:3),IuM(1:3)
  REAL(QP) deb,fin,Iu(1:3)
  INTEGER is,fich

  q=arg(1) !value of q passed on to the intu function
  fich=floor(arg(2))
  argintu(2)=q
  intom(:,:)=0.0_qp

  do is=1,size(om)
   ome=om(is)

!value of the energy denominator passed on to the intu and Iuanaly functions
   enM= ome-zk
   enP= ome+zk

   IuP(:)=0.0_qp
   IuM(:)=0.0_qp
!   call cpu_time(deb)
!   argintu(1)=enM
!   Iu=qromovq(intu,-1.0_qp,1.0_qp,3,argintu,midpntvq,EPSu) !computes int_-1^1 du (V^2,U^2,UV)/(ome-z+eps)
   IuM=Iuanaly(enM,q)
!   write(6,*)"Iu(1),IuM(1)=",Iu(1),real(IuM(1))
!   IuM(1)=cmplx(Iu(1),0.0_qp)
!   IuM(2)=cmplx(Iu(2),0.0_qp)
!   IuM(3)=cmplx(Iu(3),0.0_qp)
   IuP=Iuanaly(enP,q)
   if((isnan(real(IuM(1))).OR.isnan(real(IuP(1)))))then
    write(6,*)"isnan(IuP/M))"
    write(6,*) "enM,enP,q=",enM,enP,q
    stop
   endif

!   if(maxval(abs(Iu2-Iu))>1.0e-8_qp)then
!    write(6,*)"Iu2-Iu>1.0e-8_qp"
!   if(argintu(1)<-1.0_qp)then
!    write(6,*)"en,q =",argintu(1),q
!    write(6,*)"Iu =",Iu
!   endif
!    write(6,*)"Iu-Iu2 =",Iu-Iu2
!   endif
!   write(6,*)"Iu-Iu2 =",Iu-Iu2

!   call cpu_time(fin)
!   write(6,*)"Iu, temps écoulé=",deb-fin
!   call cpu_time(deb)

   if(lecture)then
    read(10+fich,*)xqfi,omfi,reM11,reM12,reM21,reM22,imM11,imM12,imM21,imM22
    Mat(1,1)=cmplx(reM11,imM11,kind=qpc)
    Mat(2,2)=cmplx(reM22,imM22,kind=qpc)
    Mat(1,2)=cmplx(reM12,imM12,kind=qpc)
    Mat(2,1)=Mat(1,2)
    det=Mat(1,1)*Mat(2,2)-Mat(1,2)**2
    if(abs(xq -xqfi)>1.e-13_qp)then
     stop "xq -xqfi"
    endif
    if(abs(ome-omfi)>1.e-13_qp)then
     write(6,*)"ome,omfi=",ome,omfi
     stop "ome-omfi"
    endif
   else
    call mat_pairfield(ome,e,det,Mat,Gam)
    if(ecriture)then
     write(15+fich,*)q,ome,real(Mat),imag(Mat)
    endif
   endif
   
   MatCat(1,1)=(Mat(1,1)+Mat(2,2))/2.0_qp+Mat(1,2)
   MatCat(2,2)=(Mat(1,1)+Mat(2,2))/2.0_qp-Mat(1,2)
   MatCat(1,2)=(Mat(2,2)-Mat(1,1))/2.0_qp

   Gam(1,1)=MatCat(2,2)/det
   Gam(2,2)=MatCat(1,1)/det
   Gam(1,2)=-MatCat(1,2)/det

   rho=-imag(Gam)/PI
   intom(is,1)=-rho(1,1)*IuM(1)
   intom(is,2)=-rho(2,2)*IuM(2)
   intom(is,3)=-rho(1,2)*IuM(3)

   intom(is,4)= rho(2,2)*IuP(2)
   intom(is,5)= rho(1,1)*IuP(1)
   intom(is,6)=-rho(1,2)*IuP(3)
!   call cpu_time(fin)

!   write(6,*)"lecture, temps écoulé=",deb-fin
   write(6,FMT="(A20,8G20.10)")"q,ome,real(intom)=",q,ome,real(intom(is,:))!*ome**(3.0_qp/2.0_qp)
!   write(6,FMT="(A11,3G20.10)")"imag(intom)=",imag(intom(is,:))!*ome**(3.0_qp/2.0_qp)


  enddo
 END FUNCTION intom

 FUNCTION Iuanaly(en,q) !Computes Iu analytically
  USE recettes
  IMPLICIT NONE
  REAL(QP), INTENT(IN) :: en,q
  COMPLEX(QPC) Iuanaly(1:3)
  COMPLEX(QPC) t1,t2

  REAL(QP) epsP,epsM,xiP,xiM,xi0,tmin,tmax,I1,I2,I3,imI1,imI2,rac

  Iuanaly(:)=0.0_qp
  imI1=0.0_qp
  imI2=0.0_qp
  
  xi0=k**2+q**2-x0
  xiP=k**2+q**2+2.0_qp*k*q-x0
  xiM=k**2+q**2-2.0_qp*k*q-x0
  epsP=sqrt(xiP**2+1.0_qp)
  epsM=sqrt(xiM**2+1.0_qp)
  tmax=(epsM+2.0_qp*k*q)/abs(en)
  tmin=(epsP-2.0_qp*k*q)/abs(en)
  if(abs(en)>1.0_qp)then
   rac=sqrt(en**2-1.0_qp)
   t1=cmplx((xi0-en+rac)/abs(en),0.0_qp,kind=qpc)
   t2=cmplx((xi0-en-rac)/abs(en),0.0_qp,kind=qpc)
  else
   rac=sqrt(1.0_qp-en**2)
   t1=cmplx((xi0-en)/abs(en),+rac/abs(en),kind=qpc)
   t2=cmplx((xi0-en)/abs(en),-rac/abs(en),kind=qpc)
  endif
  I1=log(abs((tmax-t1)*(tmax-t2)/(tmin-t1)/(tmin-t2)))
  I3=log((epsM-xiM)/(epsP-xiP))
  if(abs(en)<1.0_qp)then
   I2=2.0_qp*(argum(tmax-t1)-argum(tmin-t1))*abs(en)/rac
  else
   I2=log(abs((tmax-t1)*(tmin-t2)/(tmax-t2)/(tmin-t1)))*abs(en)/rac
   if((tmax>real(t1)).AND.(tmin<real(t1)))then
    imI1=imI1-PI
    imI2=imI2-PI
    write(6,*)"en,q=",en,q
    stop
   endif
   if((tmax>real(t2)).AND.(tmin<real(t2)))then
    imI1=imI1+PI
    imI2=imI2-PI
   endif
   imI2=imI2*abs(en)/rac
  endif
!  write(6,*)"I1,I2,I3=",I1,I2,I3
  Iuanaly(1)=( (I1+iiq*imI1)-sign(1.0_qp,en)*(I2+iiq*imI2))          /(4*k*q)
  Iuanaly(2)=(-(I1+iiq*imI1)-sign(1.0_qp,en)*(I2+iiq*imI2)+2.0_qp*I3)/(4*k*q)
  Iuanaly(3)=  (I2+iiq*imI2)                                         /(4*k*q*abs(en))

  
 END FUNCTION Iuanaly

 FUNCTION intu(u,arg,m) !Computes size(u) points of the function to be integrate over u
  IMPLICIT NONE
  INTEGER,  INTENT(IN) :: m ! m=3 here
  REAL(QP), INTENT(IN), DIMENSION(:)  ::  u,arg !arg(1) should be the energy in the denominator, arg(2) should be the value of q
  REAL(QP), DIMENSION(size(u),m)       ::  intu

  REAL(QP) kmq2,q,en,xi,eps,U2,V2,UV,us
  INTEGER is

  en=arg(1)
  q=arg(2)
  intu(:,:)=0.0_qp

  do is=1,size(u)

   us   =u(is)
   kmq2 =k**2+q**2-2.0_qp*k*q*us
   xi   =kmq2-x0
   eps  =sqrt(xi**2+1.0_qp)
   U2   =0.5_qp*(1.0_qp+xi/eps)
   V2   =1.0_qp-U2
   UV   =0.5_qp/eps

   intu(is,1)=V2   /(en+eps)
   intu(is,2)=U2   /(en+eps)
   intu(is,3)=UV   /(en+eps)

  enddo
 END FUNCTION intu

END FUNCTION selfE
 SUBROUTINE erreur(var)
 CHARACTER(len=*), INTENT(IN) :: var
  if(st)then
   write(6,*) "convergence non atteinte dans l’intégrale sur "//var
   stop
  else
   write(6,*) "convergence non atteinte dans l’intégrale sur "//var
  endif
 END SUBROUTINE erreur
END MODULE intldc
