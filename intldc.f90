MODULE intldc !Contribution of the branch cuts ("ldc") to the fermionic self-energy
USE vars      !Variables shared variables in the dspec module (in particular x0=mu/Delta and xq=q/q_Delta, opp(1:4), location of the angular points of the qp-qp branch cut)
USE dspec
USE modsim
USE angularint
USE OMP_LIB
IMPLICIT NONE
LOGICAL bla0,bla00,bla000
INTEGER ecrintq,ilec
REAL(QP) xiP,xiM,epsP,epsM,xmin,xmax,k0
REAL(QP),ALLOCATABLE, DIMENSION(:,:) :: donlec1,donlec2,donlec3
REAL(QP) :: bq(1:4)
INTEGER  :: profondeur
INTEGER, PARAMETER :: al=1,bet=2,gam=3,delt=4,epsi=5,alti=6,betti=7,deltti=8,epsiti=9
!$OMP THREADPRIVATE(xiP,xiM,epsP,epsM,xmin,xmax,ilec)
CONTAINS
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SUBROUTINE ini_intpasres(lecture,ecriture,fichlec)
 USE recettes
 LOGICAL, INTENT(IN)  :: lecture,ecriture
 CHARACTER(len=*), INTENT(IN) ::  fichlec

 INTEGER nl1,nl2,nl3

 if(lecture)then
  open(101,file=trim(fichlec)//".info")
   read(101,FMT="(A90)") chainebidon
   read(101,*) profondeur,bq(:) 
  close(101)

  nl1=nlignes(trim(fichlec)//"_1.dat")
  nl2=nlignes(trim(fichlec)//"_2.dat")
  nl3=nlignes(trim(fichlec)//"_3.dat")
  if(bla0) write(6,*)"ini_intpasres"
  if(bla0) write(6,*)
  if(bla0) write(6,*)"fichlec,nl1,nl2,nl3=",trim(fichlec),nl1,nl2,nl3
  allocate(donlec1(1:10,1:nl1))
  allocate(donlec2(1:10,1:nl2))
  allocate(donlec3(1:10,1:nl3))

  open(111,file=trim(fichlec)//"_1.dat")
   do ilec=1,nl1
    read(111,*)donlec1(1:10,ilec)
   enddo
  close(111)

  open(112,file=trim(fichlec)//"_2.dat")
   do ilec=1,nl2
    read(112,*)donlec2(1:10,ilec)
   enddo
  close(112)

  open(112,file=trim(fichlec)//"_3.dat")
   do ilec=1,nl3
    read(112,*)donlec3(1:10,ilec)
   enddo
  close(112)

 endif

 if(ecriture)then

  open(101,file=trim(fichlec)//".info")
   write(101,*)"! grille de valeur de q,om et Mat de pour profondeur, bq="
   write(101,*) profondeur,bq
  close(101)

  open(111,file=trim(fichlec)//"_1.dat")
  open(112,file=trim(fichlec)//"_2.dat")
  open(113,file=trim(fichlec)//"_3.dat")

 endif
 if(bla0)then
   write(6,*)
   write(6,*)"+++++++++++++++++++++++++++ ini_intpasres +++++++++++++++++++++++++"
   write(6,*)
   write(6,*)"lecture,ecriture=",lecture,ecriture
   write(6,*)"q1,q2,q3,q4=",bq
   write(6,*)"fichlec: ",trim(fichlec)
   write(6,*)"profondeur=",profondeur
   write(6,*)
   write(6,*)"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 endif
END SUBROUTINE ini_intpasres
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SUBROUTINE desini(lecture,ecriture)
 LOGICAL, INTENT(IN)  :: lecture,ecriture
 if(lecture)then
  deallocate(donlec1,donlec2,donlec3)
 endif
 if(ecriture)then
  close(111)
  close(112)
  close(113)
 endif
END SUBROUTINE desini
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FUNCTION intpasres(k,zk,lecture,ecriture,EPS,suffixe)
 REAL(QP), INTENT(IN) :: k,zk
 REAL(QP), INTENT(IN) :: EPS(1:2)
 LOGICAL, INTENT(IN)  :: lecture,ecriture
 CHARACTER(len=*), INTENT(IN) ::  suffixe
 REAL(QP) intpasres(1:6)

 CHARACTER(len=90) prefixe
 REAL(QP) Iq1(1:6),Iq2(1:6),Iq3(1:6),Iqinf(1:6)
 REAL(QP) argq(1:1),e,EPSq,EPSom
 LOGICAL err

 e=0.0_qp
 EPSq =EPS(1)
 EPSom=EPS(2)


 if(bla0)then
   write(6,*)"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   write(6,*)
   write(6,*)"+++++++++++++++++++++++++++++ intpasres ++++++++++++++++++++++++++++"
   write(6,*)
   write(6,*)"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   write(6,*)
   write(6,*)"k,zk=",k,zk
   write(6,*)"lecture,ecriture=",lecture,ecriture
   write(6,*)"q1,q2,q3,q4=",bq
   write(6,*)
   write(6,*)"EPSq,EPSom,profondeur=",EPSq,EPSom,profondeur
   write(6,*)
   write(6,*)"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 endif

 prefixe="pasres"

 if(ecrintq.GE.2)then
  !$OMP CRITICAL
  open(120,file="intq"//trim(prefixe)//trim(suffixe)//".dat")
  close(120)
  !$OMP END CRITICAL
 endif

 Iq1(:)=0.0_qp
 Iq2(:)=0.0_qp
 Iq3(:)=0.0_qp

 ilec=1
 argq(1)=bidon
 Iq1=qromovfixed(intq,bq(1) ,   bq(2),   6,argq,midpntvq,EPSq,profondeur,err)
 if(bla0) write(6,*)"Iq1=",Iq1
 if(err)  call erreur("q")

 ilec=1
 argq(1)=bidon
 Iq2=qromovfixed(intq,bq(2),    bq(3),   6,argq,midpntvq,EPSq,profondeur,err)
 if(bla0) write(6,*)"Iq2=",Iq2
 if(err)  call erreur("q")

 ilec=1
 argq(1)=bidon
 Iq3=qromovfixed(intq,bq(3),    bq(4),   6,argq,midpntvq,EPSq,profondeur,err)
 if(bla0) write(6,*)"Iq3=",Iq3
 if(err)  call erreur("q")

 Iqinf(:)=0.0_qp
 Iqinf(1)=1.0_qp/(2.0_qp*sqrt(3.0_qp)*PI**3*bq(3)**4)
 Iqinf(5)=-Iqinf(1)
! For the other integrals, the large q contribution (vanishing at least as 1/bq3**6) is neglected

 intpasres=2.0_qp*PI*(Iq1+Iq2+Iq3+Iqinf) !Integration sur phi
 if(bla0) write(6,*)"intpasres=",intpasres


CONTAINS

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 FUNCTION intq(q,argq,m) !Computes size(q) points of the function to be integrate over q
  USE nrutil
  INTEGER,  INTENT(IN) :: m !m=6: the 3 coefficients of the 1<->3 self-energy matrix and the 3 coeff of the 4<->0 process
  REAL(QP), INTENT(IN), DIMENSION(:)  ::  q,argq
  REAL(QP)  intq(size(q),m)

  REAL(QP), DIMENSION(1:6) ::  I,Ia,Ib,Ic,Id,Ie
  REAL(QP)   , DIMENSION(1:6) ::  Iinf
  REAL(QP) bmax,qs
  INTEGER is
 
  intq(:,:)=0.0_qp
 
  do is=1,size(q)
   qs=q(is) !Current value of q, passed on to the intom function in its "arg" argument 
   xq=qs
   call oangpp

   if(bla00)then
    write(6,*)"----------------------------------------"
    write(6,*)
    write(6,*)"qs=",qs
    write(6,*)"ptbranchmtpp=",ptbranchmtpp
    write(6,*)"opp=",opp
    write(6,*)
   endif
  
   xiP=k**2+qs**2+2.0_qp*k*qs-x0
   xiM=k**2+qs**2-2.0_qp*k*qs-x0
   epsP=sqrt(xiP**2+1.0_qp)
   epsM=sqrt(xiM**2+1.0_qp)

   xmin=epsP-xiP
   xmax=epsM-xiM

   Ia(:)=0.0_qp
   Ib(:)=0.0_qp
   Ic(:)=0.0_qp
   Id(:)=0.0_qp
   Ie(:)=0.0_qp
   I(:) =0.0_qp
   intq(is,:)=0.0_qp
   
   bmax =1.e6_qp

   Iinf(1)=(xmax-xmin)            /(       sqrt(2.0_qp)*PI**3*k*qs*bmax**(1.0_qp/2.0_qp))
   Iinf(2)=(xmin**(-1)-xmax**(-1))/(9.0_qp*sqrt(2.0_qp)*PI**3*k*qs*bmax**(9.0_qp/2.0_qp))
   Iinf(3)=log(xmax/xmin)         /(5.0_qp*sqrt(2.0_qp)*PI**3*k*qs*bmax**(5.0_qp/2.0_qp))
   Iinf(4)=-Iinf(2)
   Iinf(5)=-Iinf(1)
   Iinf(6)= Iinf(3)
   if(bla00)then
     write(6,FMT="(A6,6G20.10)")"Iinf=",Iinf
   endif
  
   if(ptbranchmtpp==1)then !BEC-like behavior: integrate from branch cut lower-edge opp(1) to infinity
     Ib=qromovfixed(intom,opp(1)         ,bmax                ,6,(/qs/),racinfvq,EPSom,profondeur,err) !deals with the 1/om^(3/2) decay at large om
     if(bla00) write(6,FMT="(A10,6G20.10)")'Ib=',Ib
     if(err)  call erreur("omega")

   elseif(ptbranchmtpp==2)then !One angular point opp(2) besides the lower-edge
    Ib=qromovfixed(intom,opp(1)         ,opp(2)              ,6,(/qs/),midpntvq,EPSom,profondeur,err) !Integrate from the edge to the angular point
    if(bla00) write(6,FMT="(A10,6G20.10)")'Ib=',Ib
    if(err)  call erreur("omega")

    Ic=qromovfixed(intom,opp(2)         ,2.0_qp*opp(2)       ,6,(/qs/),midpntvq,EPSom,profondeur,err) !then from opp(2) to 2*opp(2), this circumscribes the numerical difficulty around opp(2)
    if(bla00) write(6,FMT="(A10,6G20.10)")'Ic=',Ic
    if(err)  call erreur("omega")

    Id=qromovfixed(intom,2.0_qp*opp(2)  ,bmax                ,6,(/qs/),racinfvq,EPSom,profondeur,err) !then from 2*opp(2) to infinity
    if(bla00) write(6,FMT="(A10,6G20.10)")'Id=',Id
    if(err)  call erreur("omega")

   elseif(ptbranchmtpp==3)then !Two angular points opp(2) and opp(3) besides the lower-edge
    Ib=qromovfixed(intom,opp(1)         ,opp(2)              ,6,(/qs/),midpntvq,EPSom,profondeur,err)
    if(bla00) write(6,FMT="(A10,6G20.10)")'Ib=',Ib
    if(err)  call erreur("omega")

    Ic=qromovfixed(intom,opp(2)         ,opp(3)              ,6,(/qs/),midpntvq,EPSom,profondeur,err)
    if(bla00) write(6,FMT="(A10,6G20.10)")'Ic=',Ic
    if(err)  call erreur("omega")

    Id=qromovfixed(intom,opp(3)         ,2.0_qp*opp(3)       ,6,(/qs/),midpntvq,EPSom,profondeur,err)
    if(bla00) write(6,FMT="(A10,6G20.10)")'Id=',Id
    if(err)  call erreur("omega")

    Ie=qromovfixed(intom,2.0_qp*opp(3)  ,bmax                ,6,(/qs/),racinfvq,EPSom,profondeur,err)
    if(bla00) write(6,FMT="(A10,6G20.10)")'Ie=',Ie
    if(err)  call erreur("omega")
   endif
  
   I=Ib+Ic+Id+Ie+Iinf !Combine the integration intervals
   if(bla00)then
    write(6,*)
    write(6,FMT="(A12,7G20.10)")"qs,real(I)=",qs,real(I)
   endif


   intq(is,:)=I(:)*qs**2 !Jacobian of the q integration

  if(ecrintq.GE.1)then
   !$OMP CRITICAL
   open(120,file="intq"//trim(prefixe)//trim(suffixe)//".dat",POSITION="APPEND")
    write(120,*)qs,real(intq(is,1:6))
   close(120)
   !$OMP END CRITICAL
  endif
  
  enddo

 END FUNCTION intq

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 FUNCTION intom(om,arg,m) !Computes size(om) points of the function  to be integrate over om
  IMPLICIT NONE
  INTEGER,  INTENT(IN) :: m !m=6 here
  REAL(QP), INTENT(IN), DIMENSION(:)  ::  om,arg !arg(1) should be the value of q
  REAL(QP), DIMENSION(size(om),m)       ::  intom

  COMPLEX(QPC) Gam(1:2,1:2),Mat(1:2,1:2),MatCat(1:2,1:2),det
  REAL(QP) reM11,reM22,reM12,reM21,imM11,imM22,imM12,imM21,omfi,xqfi
  REAL(QP) q,rho(1:2,1:2),ome,enM,enP
  COMPLEX(QPC) IuP(1:3),IuM(1:3)
  INTEGER is,fich

  q=arg(1) !value of q passed on to the intu function
  if    (q>bq(3))then
   fich=3
  elseif(q>bq(2))then
   fich=2
  else
   fich=1
  endif
  intom(:,:)=0.0_qp

  if((bla000).AND.(size(om)==1))then
   write(6,*)
   write(6,*)"****************"
  endif

  do is=1,size(om)
   ome=om(is)

!value of the energy denominator passed on to the intu and Iuanaly functions
   enM= ome-zk
   enP= ome+zk

   IuP(:)=0.0_qp
   IuM(:)=0.0_qp
   IuM=conjg(Iuanaly(enM,k,q,xmin,xmax)) !enM a une (petite) partie imaginaire négative venant de -zk
   IuP=      Iuanaly(enP,k,q,xmin,xmax)

   if(lecture)then
    if(fich==1)then
     xqfi=donlec1(1,ilec);omfi=donlec1(2,ilec)
     Mat(1,1)=cmplx(donlec1(3,ilec),donlec1(7 ,ilec),kind=qpc)
     Mat(2,2)=cmplx(donlec1(6,ilec),donlec1(10,ilec),kind=qpc)
     Mat(1,2)=cmplx(donlec1(4,ilec),donlec1(8 ,ilec),kind=qpc)
    elseif(fich==2)then
     xqfi=donlec2(1,ilec);omfi=donlec2(2,ilec)
     Mat(1,1)=cmplx(donlec2(3,ilec),donlec2(7 ,ilec),kind=qpc)
     Mat(2,2)=cmplx(donlec2(6,ilec),donlec2(10,ilec),kind=qpc)
     Mat(1,2)=cmplx(donlec2(4,ilec),donlec2(8 ,ilec),kind=qpc)
    elseif(fich==3)then
     xqfi=donlec3(1,ilec);omfi=donlec3(2,ilec)
     Mat(1,1)=cmplx(donlec3(3,ilec),donlec3(7 ,ilec),kind=qpc)
     Mat(2,2)=cmplx(donlec3(6,ilec),donlec3(10,ilec),kind=qpc)
     Mat(1,2)=cmplx(donlec3(4,ilec),donlec3(8 ,ilec),kind=qpc)
    endif
    ilec=ilec+1
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
     write(110+fich,*)q,ome,real(Mat),imag(Mat)
    endif
   endif
   
   MatCat(1,1)=(Mat(1,1)+Mat(2,2))/2.0_qp+Mat(1,2)
   MatCat(2,2)=(Mat(1,1)+Mat(2,2))/2.0_qp-Mat(1,2)
   MatCat(1,2)=(Mat(2,2)-Mat(1,1))/2.0_qp

   Gam(1,1)= MatCat(2,2)/det
   Gam(2,2)= MatCat(1,1)/det
   Gam(1,2)=-MatCat(1,2)/det

   rho=-imag(Gam)/PI

   intom(is,1)=-rho(1,1)*IuM(1)
   intom(is,2)=-rho(2,2)*IuM(2)
   intom(is,3)=-rho(1,2)*IuM(3)

   intom(is,4)= rho(2,2)*IuP(2)
   intom(is,5)= rho(1,1)*IuP(1)
   intom(is,6)=-rho(1,2)*IuP(3)

   if(bla000)then
    write(6,FMT="(A19,8G20.10)")"q,ome,real(intom)=",q,ome,intom(is,1:6)
   endif

  enddo

  if(bla000)then
   write(6,*)
  endif

 END FUNCTION intom
END FUNCTION intpasres
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SUBROUTINE erreur(var)
CHARACTER(len=*), INTENT(IN) :: var
if(bla0) write(6,*) "convergence non atteinte dans l’intégrale sur "//var
!read(5,*)
END SUBROUTINE erreur

! @@
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FUNCTION intres(k,zk,interpolation,EPS,bk,le,suffixe)
 USE estM
 USE recettes
 REAL(QP), INTENT(IN) :: k,zk
 LOGICAL,  INTENT(IN) :: interpolation
 CHARACTER(len=*), INTENT(IN) :: suffixe
 REAL(QP), INTENT(IN) :: EPS(1:2),bk(0:12),le(1:8)
 COMPLEX(QPC) intres(1:6)

 INTEGER,  ALLOCATABLE, DIMENSION(:) :: config
 REAL(QP), ALLOCATABLE, DIMENSION(:) :: bq

 CHARACTER(len=2) reg
 CHARACTER(len=90) :: prefixe
 INTEGER tconf,configbis(1:7)
 REAL(QP) :: bk2(0:12),le2(1:8)
 REAL(QP) e,qdep,qsup,qmax,bqbis(1:8)
 REAL(QP) EPSq,EPSom
 COMPLEX(QPC) ires(1:6),ires1(1:6),ires2(1:6)

 INTEGER grecque,igr

 EPSq =EPS(1)
 EPSom=EPS(2)

 k0=bk(0)
 call bornesq (k,zk-2.0_qp,bk,le,reg,tconf,configbis,bqbis)
 temperaturenulle=.TRUE.
 e=0.0_qp

 allocate(bq(1:tconf+1))
 allocate(config(1:tconf))
 bq    =bqbis(1:tconf+1)
 config=configbis(1:tconf)

 bk2=bk; le2=le
 call tri(bk2)
 call tri(le2)


 if(bla0)then
   write(6,*)"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   write(6,*)
   write(6,*)"++++++++++++++++++++++++++++++ intres +++++++++++++++++++++++++++++"
   write(6,*)
   write(6,*)"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   write(6,*)
   write(6,*)
   write(6,*)"k,zk=",k,zk
   write(6,FMT="(A3,12G20.10)")"bk=",bk2
   write(6,FMT="(A3,8G20.10)") "le=",le2
   write(6,*)                  "reg=",reg
   write(6,*)                  "config=",ecritconfig(tconf,config) 
   write(6,*)                  "bq="    ,bq(1:tconf+1)
 endif

 prefixe="res"

 intres(:)=cmplx(0.0_qp,0.0_qp,kind=qpc)

 bmax =1.e6_qp
 if(ecrintq.GE.2)then
  !$OMP CRITICAL
  open(125,file="intq"//trim(prefixe)//trim(suffixe)//".dat")
  close(125)
  !$OMP END CRITICAL
 endif

 if((.NOT.allocated(donnees)).AND.(interpolation)) stop "Impossible d’interpoler, donnees est vide"

! Partie non résonante à grands q
 grecque=0
 if(tconf==0)then
  qdep=0.0_qp
  qsup =4.0_qp*k0
 else
  qdep=bq(tconf+1)
  qsup =2.0_qp*bq(tconf+1)
 endif
 
 write(6,*)"ggq=",ggq
 if(interpolation)then
   qmax= max(ggq     ,2*qsup)
 else
   qmax= max(100.0_qp,2*qsup)
 endif

 if(bla0) write(6,*)"bornes=",qdep,qsup
 ires1=qromovcq(intresq,qdep,qsup,6,(/bidon/),midsqlvcq,EPSq)
 if(bla0)then
  write(6,*)
  write(6,FMT="(A9,6G20.10)")"re(ires1)=",real(ires1)
  write(6,FMT="(A9,6G20.10)")"im(ires1)=",imag(ires1)
  write(6,*)"---------------------------------"
 endif
 if(bla0) write(6,*)"bornes=",qsup,qmax
 ires2=qromovcq(intresq,qsup,qmax,6,(/bidon/),midsqlvcq,EPSq)
 if(bla0)then
  write(6,*)
  write(6,FMT="(A9,6G20.10)")"re(ires2)=",real(ires2)
  write(6,FMT="(A9,6G20.10)")"im(ires2)=",imag(ires2)
  write(6,*)"---------------------------------"
 endif
 intres=ires1+ires2
 if(tconf>0)then
  do igr=1,tconf
   grecque=config(igr)
   if(bla0)then
    write(6,*)"---------------------------------"
    write(6,*)
    write(6,*)"igr/total=",igr,"/",tconf
    write(6,*)"bq(igr),bq(igr+1)=",bq(igr),bq(igr+1)
    write(6,*)
   endif
   if(abs(bq(igr+1)-bq(igr)).LE.1.0e-10) write(6,*) "On saute ce petit intervalle en q de taille :",abs(bq(igr+1)-bq(igr))
   if(abs(bq(igr+1)-bq(igr)).LE.1.0e-10) cycle
   ires=qromovcq(intresq,bq(igr),bq(igr+1),6,(/bidon/),midpntvcq,EPSq)
   intres=intres+ires
   if(bla0)then
    write(6,*)
    write(6,FMT="(A9,6G20.10)")"re(ires)=",real(ires)
    write(6,FMT="(A9,6G20.10)")"im(ires)=",imag(ires)
    write(6,*)"---------------------------------"
   endif
  enddo
 endif
 intres=2.0_qp*PI*intres

 CONTAINS
  FUNCTION intresq(q,argq,m)
  USE nrutil
  USE recettes
  USE modsim
  INTEGER,  INTENT(IN) :: m !m=6
  REAL(QP), INTENT(IN), DIMENSION(:)  ::  q,argq
  COMPLEX(QPC)  intresq(size(q),m)

  COMPLEX(QPC)  Iinf(m)
  REAL(QP) qs,ommil
  REAL(QP) bom(1:3),bom2(1:6)
  INTEGER is,ttot,tres,trout,res(1:2),pos_bom(1:6),p1,p2
  REAL(QP), ALLOCATABLE, DIMENSION(:,:) :: arg
  REAL(QP), ALLOCATABLE, DIMENSION(:)   :: bomf
  INTEGER,  ALLOCATABLE, DIMENSION(:)   :: vres,routint
  INTEGER itai

  do is=1,size(q)
  
   qs=q(is)
   xq=qs
   call oangpp
   call bornesom(k,zk,qs,grecque,res,bom,tres)
 
   xiP=k**2+qs**2+2.0_qp*k*qs-x0
   xiM=k**2+qs**2-2.0_qp*k*qs-x0
   epsP=sqrt(xiP**2+1.0_qp)
   epsM=sqrt(xiM**2+1.0_qp)
 
   xmin=epsP-xiP
   xmax=epsM-xiM

   if(bla0)then
!   if(bla00.AND.(omp_get_thread_num()==0))then
    write(6,*)"---------------------------------"
    write(6,*)
    write(6,*)"qs,is,boucle=",qs,is,"/",size(q),nint(2+log(size(q)/2.0_qp)/log(3.0_qp))
    write(6,*)"grecque,igr/total=",ecritc(grecque),igr,"/",tconf
    write(6,*)"ptbranchmtpp=",ptbranchmtpp
    write(6,*)"opp=",opp
    if(grecque.NE.0) write(6,*)"res=",res(1:tres)
    write(6,FMT="(A5,3G20.10)")"bom=",bom
    write(6,*)"fil,k,zk:",omp_get_thread_num(),k,zk
   endif

!Combine les points anguleux de opp avec ceux de bom
   bom2(:)=1.e100_qp
   if(grecque==0)then
    ttot=ptbranchmtpp !ttot=nbr tot de points anguleux.
    bom2(1:ptbranchmtpp)=opp(1:ptbranchmtpp)
   elseif((grecque==al).OR.(grecque==alti).OR.(grecque==bet).OR.(grecque==betti).OR.(grecque==gam))then
    ttot=tres+ptbranchmtpp !Dans ce cas bom(1)=opp(1): on évite le double comptage
    bom2(1:ptbranchmtpp)=opp(1:ptbranchmtpp)
    bom2(ptbranchmtpp+1:ptbranchmtpp+tres)=bom(2:tres+1)
   else
    ttot=tres+ptbranchmtpp+1 !Dans ce cas bom(1).NE.opp(1)
    bom2(1:ptbranchmtpp)=opp(1:ptbranchmtpp)
    bom2(ptbranchmtpp+1:ptbranchmtpp+tres+1)=bom(1:tres+1)
   endif
   call tri_pos(bom2,pos_bom)
 
!Découpe les intervalles par le milieu, assigne routint (pour le changement de variable) et vres (pour le nombre d’angles de résonnance)
   trout=2*ttot !trout=nombre d’intervalle d’integration. Nombre de bornes (avec les milieux et bmax: 2*ttot)
   allocate(bomf(1:trout+1))
   allocate(routint(1:trout))
   allocate(vres(1:trout))
   vres(:)   =0
   routint(:)=mpnt
   do itai=1,ttot-1
    p1=pos_bom(itai)
    p2=pos_bom(itai+1)
    ommil=(bom2(itai)+bom2(itai+1))/2
    bomf(2*itai-1)=bom2(itai)
    bomf(2*itai)  =ommil
    if(p1>ptbranchmtpp) routint(2*itai-1)=msql
    if(p2>ptbranchmtpp) routint(2*itai)  =msqu
!    if((ptbranchmtpp==3).AND.(p1==2)) routint(2*itai-1)  =msql
    if(grecque.NE.0)then 
     call locate(bom(1:tres+1),ommil,p1)
     if((p1>0).AND.(p1<tres+1))then
       vres(2*itai-1:2*itai)=res(p1)
     endif
    endif
   enddo
   bomf(trout-1)  =bom2(ttot)
   bomf(trout)=2*bomf(trout-1)
   bomf(trout+1)=bmax
   routint(trout-1)=msql
   routint(trout)=rinf
   vres(trout)=0

   allocate(arg(1:2,1:trout))
   arg(1,:)=qs
   arg(2,:)=vres(:)+0.5_qp

   if(bla0)then
!   if(bla00.OR.(omp_get_thread_num()==0))then
    write(6,FMT="(A6,10G20.10)")"bomf=",bomf(1:trout+1)
    write(6,*)"routint=",ecritrout(trout,routint(1:trout))
    write(6,*)"vres="   ,vres(1:trout)
    write(6,*)
   endif

!  Intégration analytique de bmax à +oo
   Iinf(1)=(xmax-xmin)            /(       sqrt(2.0_qp)*PI**3*k*qs*bmax**(1.0_qp/2.0_qp))
   Iinf(2)=(xmin**(-1)-xmax**(-1))/(9.0_qp*sqrt(2.0_qp)*PI**3*k*qs*bmax**(9.0_qp/2.0_qp))
   Iinf(3)=log(xmax/xmin)         /(5.0_qp*sqrt(2.0_qp)*PI**3*k*qs*bmax**(5.0_qp/2.0_qp))
   Iinf(4)=-Iinf(2)
   Iinf(5)=-Iinf(1)
   Iinf(6)= Iinf(3)

   if(bla000)then
    write(6,*)"Iinf=",real(Iinf(1:6))
    write(6,*)
    write(6,*)"************************"
    write(6,*)
    write(6,*)"        decoupe         "
    write(6,*)
   endif
   intresq(is,:)=decoupevcq(intresom,bomf(1:trout+1),6,arg,routint(1:trout),EPSom,bla00)
   intresq(is,:)=intresq(is,:)+Iinf(:)
   intresq(is,:)=intresq(is,:)*qs**2

   if(ecrintq.GE.1)then
    !$OMP CRITICAL
    open(125,file="intq"//trim(prefixe)//trim(suffixe)//".dat",POSITION="APPEND")
     write(125,*)qs,real(intresq(is,:)),imag(intresq(is,1:3))
    close(125)
    !$OMP END CRITICAL
   endif
!   if(bla0.AND.(omp_get_thread_num()==0))then
   if(bla00)then
     write(6,FMT="(A7,6G20.10)")"intresq=",real(intresq(is,1:3)),imag(intresq(is,1:3))
     write(6,*)
   endif

   deallocate(bomf)
   deallocate(routint)
   deallocate(vres)
   deallocate(arg)
  enddo
  END FUNCTION intresq
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  FUNCTION intresom(om,arg,m) !Computes size(om) points of the function  to be integrate over om
   IMPLICIT NONE
   INTEGER,  INTENT(IN) :: m !m=6 here
   REAL(QP), INTENT(IN), DIMENSION(:)  ::  om,arg !arg(1) should be the value of q
   COMPLEX(QPC), DIMENSION(size(om),m)       ::  intresom

   COMPLEX(QPC) Gam(1:2,1:2),Matt(1:2,1:2),MatCat(1:2,1:2),det
   REAL(QP) q,rho(1:2,1:2),ome,enP,enM
   COMPLEX(QPC) IuP(1:3),IuM(1:3)
   INTEGER is,r

   q=arg(1) 
   r=floor(arg(2))!Number of resonance angles
   intresom(:,:)=0.0_qp

   if(bla000.AND.(size(om)==1))then
!   if(bla000.AND.(size(om)==1).AND.(omp_get_thread_num()==0))then
    write(6,*)"************************"
   endif

   do is=1,size(om)
    ome=om(is)

    enM= ome-zk
    enP= ome+zk
  
    IuM(:)=0.0_qp
    IuP(:)=0.0_qp

    IuM=conjg(Iuanaly(enM,k,q,xmin,xmax)) !enM a une (petite) partie imaginaire négative venant de -zk
    IuP=      Iuanaly(enP,k,q,xmin,xmax)
  
    if(interpolation)then
     call estmat_pairfield(ome,e,det,Matt,Gam)
    else
     call mat_pairfield(ome,e,det,Matt,Gam)
    endif
    
    MatCat(1,1)=(Matt(1,1)+Matt(2,2))/2.0_qp+Matt(1,2)
    MatCat(2,2)=(Matt(1,1)+Matt(2,2))/2.0_qp-Matt(1,2)
    MatCat(1,2)=(Matt(2,2)-Matt(1,1))/2.0_qp
  
    Gam(1,1)= MatCat(2,2)/det
    Gam(2,2)= MatCat(1,1)/det
    Gam(1,2)=-MatCat(1,2)/det
  
    rho=-imag(Gam)/PI
  
    intresom(is,1)=-rho(1,1)*IuM(1)
    intresom(is,2)=-rho(2,2)*IuM(2)
    intresom(is,3)=-rho(1,2)*IuM(3)
  
    intresom(is,4)= rho(2,2)*IuP(2)
    intresom(is,5)= rho(1,1)*IuP(1)
    intresom(is,6)=-rho(1,2)*IuP(3)

!    if(bla000.OR.(omp_get_thread_num()==0))then
    if(bla000)then
     write(6,FMT="(A21,8G20.10)")"k,zk,q,ome,real(intresom)=",k,zk,q,ome,real(intresom(is,2)),imag(intresom(is,2))
    endif

  enddo
!  if(bla000.OR.(omp_get_thread_num()==0))then
  if(bla000)then
   write(6,*)
  endif
  END FUNCTION intresom
END FUNCTION intres
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SUBROUTINE bornesk(bk)
REAL(QP), INTENT(OUT) :: bk(0:12)

bk(0)=sqrt(x0)
k0=bk(0)
bk(1)=k0/sqrt(2.0_qp)
bk(2)=3*k0/5
bk(3)=k0/2
bk(4)=k0/sqrt(5.0_qp)
bk(5)=k0/3
bk(6)=(sqrt(2.0_qp)-1)*k0/2
bk(7)=k0/5

bk(8) =(1+sqrt(2.0_qp))*k0/2
bk(9) =sqrt(2.0_qp)*k0
bk(10)=-k0+sqrt(4*k0**2+2*sqrt(k0**4+2*sqrt(1+k0**4)-2))
bk(11)=2*k0
bk(12)=3*k0

END SUBROUTINE bornesk
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SUBROUTINE lignesenergie(k,le)
USE recettes
REAL(QP), INTENT(IN) :: k
REAL(QP), INTENT(OUT) :: le(1:8)

le(:)=1.0e50_qp

!lignes d’énergie
le(1)=epsBCS(k)
le(5)=epsBCS(0.0_qp)
le(7)=1.0_qp
le(8)=1.0_qp
if(k<k0)then
 le(2)=epsBCS(2*k-k0)
 le(3)=epsBCS(2*k+k0)
 le(4)=epsBCS(k+sqrt(k0**2-k**2))
elseif(k<3*k0)then
 le(2)=epsBCS(2*k-k0)
 le(3)=epsBCS(2*k+k0)+ec(k+k0)-2
 if(k<2*k0)then
  le(4)=solom2(k)
 endif
 le(6)=ec(k+k0)-1
else
 le(2)=epsBCS(2*k-k0)+ec(k-k0)-2
 le(3)=epsBCS(2*k+k0)+ec(k+k0)-2
 le(6)=ec(k+k0)-1
 le(7)=ec(k-k0)-1
 le(8)=3*epsBCS(k/3.0_qp)-2
endif
if(bla0) write(6,*)"lignes d’energie non triées:",le
END SUBROUTINE lignesenergie
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SUBROUTINE bornesq(k,zkt,bk,le,reg,tconf,config,bq)
USE recettes
REAL(QP), INTENT(IN) :: k,zkt
CHARACTER(len=2), INTENT(OUT) :: reg
INTEGER, INTENT(OUT) :: tconf
INTEGER, DIMENSION(1:7), INTENT(OUT) :: config
REAL(QP), INTENT(OUT) :: bq(1:8)
REAL(QP), INTENT(IN)  :: le(1:8),bk(0:12)

REAL(QP) km,kp,qm,q1m,q2m,q3m,q4m,q1p,q2p,q1mbis,q3mbis,q2pbis,qc,qd
REAL(QP) vecq(1:13)

!reg et configuration
if(k<bk(0))then
 if(zkt<le(8))then
  reg="00"
  tconf=0
 elseif(min(le(1),le(4))>zkt)then
  reg="A0"
  tconf=6
  config(1:tconf)=(/0,alti,betti,gam,bet,al/)
 elseif((zkt>le(1)).AND.(min(le(2),le(4))>zkt))then
  reg="B0"
  tconf=6
  config(1:tconf)=(/deltti,alti,betti,gam,bet,al/)
 elseif((zkt>le(4)).AND.(min(le(1),le(2))>zkt))then
  reg="B1"
  tconf=7
  config(1:tconf)=(/0,alti,betti,epsiti,epsi,bet,al/)
 elseif((zkt>le(2)).AND.(le(4)>zkt))then
  reg="C0"
  tconf=6
  config(1:tconf)=(/deltti,epsiti,betti,gam,bet,al/)
 elseif((le(2)>zkt).AND.(zkt>max(le(1),le(4))))then
  reg="C1"
  tconf=7
  config(1:tconf)=(/deltti,alti,betti,epsiti,epsi,bet,al/)
 elseif((min(le(1),le(3))>zkt).AND.(zkt>le(2)))then
  reg="C2"
  tconf=7
  config(1:tconf)=(/0,alti,deltti,epsiti,epsi,bet,al/)
 elseif((zkt>le(4)).AND.(le(5)>zkt).AND.(k>bk(1)))then
  reg="D0"
  tconf=7
  config(1:tconf)=(/deltti,epsiti,epsi,bet,gam,bet,al/)
 elseif((zkt>max(le(2),le(4))).AND.(le(5)>zkt).AND.(k>bk(3)))then
  reg="D1"
  tconf=7
  config(1:tconf)=(/deltti,epsiti,betti,epsiti,epsi,bet,al/)
 elseif((zkt>max(le(1),le(2))).AND.(min(le(3),le(5))>zkt).AND.(k>bk(7)))then
  reg="D2"
  tconf=7
  config(1:tconf)=(/deltti,alti,deltti,epsiti,epsi,bet,al/)
 elseif((le(1)>zkt).AND.(zkt> le(3)))then
  reg="D3"
  tconf=7
  config(1:tconf)=(/0,alti,deltti,epsiti,epsi,delt,al/)
 elseif((le(3)>zkt).AND.(zkt>le(5)))then
  reg="E0"
  tconf=5
  config(1:tconf)=(/deltti,epsiti,epsi,bet,al/)
 elseif((le(5)>zkt).AND.(zkt>max(le(1),le(3))))then
  reg="E1"
  tconf=7
  config(1:tconf)=(/deltti,alti,deltti,epsiti,epsi,delt,al/)
 elseif(zkt>max(le(3),le(5)))then
  reg="F0"
  tconf=5
  config(1:tconf)=(/deltti,epsiti,epsi,delt,al/)
 else
  stop "Erreur dans region k<k0"
 endif
else
 if(le(8)>zkt)then
  reg="00"
  tconf=0
 elseif((min(le(1),le(5))>zkt).AND.(zkt>le(6)))then
  reg="A0"
  tconf=6
  config(1:tconf)=(/0,al,bet,gam,bet,al/)
 elseif((min(le(2),le(5))>zkt).AND.(zkt>le(1)))then
  reg="B0"
  tconf=6
  config(1:tconf)=(/delt,al,bet,gam,bet,al/)
 elseif((zkt>max(le(6),le(5))).AND.(le(1)>zkt))then
  reg="B1"
  tconf=4
  config(1:tconf)=(/0,al,bet,al/)
 elseif((zkt>le(2)).AND.(le(5)>zkt))then
  reg="D0"
  tconf=6
  config(1:tconf)=(/delt,epsi,bet,gam,bet,al/)
 elseif((le(2)>zkt).AND.(zkt>max(le(1),le(5))))then
  reg="D1"
  tconf=4
  config(1:tconf)=(/delt,al,bet,al/)
 elseif((zkt>max(le(2),le(5))).AND.(le(3)>zkt))then
  reg="E0"
  tconf=4
  config(1:tconf)=(/delt,epsi,bet,al/)
 elseif(zkt>le(3))then
  reg="F0"
  tconf=4
  config(1:tconf)=(/delt,epsi,delt,al/)
 elseif((k<bk(11)).AND.((zkt<le(4)).OR.((zkt>le(5)).AND.(le(6)>zkt))))then
  reg="G0"
  tconf=4
  config(1:tconf)=(/0,al,bet,gam/)
 elseif((k>bk(11)).AND.(bk(12)>k).AND.(le(6)>zkt))then
  reg="G0"
  tconf=4
  config(1:tconf)=(/0,al,bet,gam/)
 elseif((k>bk(12)).AND.(le(6)>zkt).AND.(zkt>le(7)))then
  reg="G0"
  tconf=4
  config(1:tconf)=(/0,al,bet,gam/)
 elseif((k>bk(12)).AND.(le(7)>zkt).AND.(zkt>le(8)))then
  reg="H0"
  tconf=2
  config(1:tconf)=(/0,al/)
 elseif((k<bk(11)).AND.(min(le(5),le(6))>zkt).AND.(zkt>le(4)))then
  reg="J0"
  tconf=6
  config(1:tconf)=(/0,al,bet,gam,bet,gam/)
 else 
  stop "Erreur dans region k>k0"
 endif
endif

!bornesq
km=    1.0e50_qp; kp=    1.0e50_qp; q1m=   1.0e50_qp; q2m=   1.0e50_qp; q3m=   1.0e50_qp; q4m=   1.0e50_qp; 
q1mbis=1.0e50_qp; q3mbis=1.0e50_qp; 
q1p=   1.0e50_qp; q2p=   1.0e50_qp; 
qc=    1.0e50_qp; qm=    1.0e50_qp;

if(k<k0)then
 km=k0-k
 kp=k+k0
 if((le(5)>zkt).AND.(zkt>le(1))) q1m=k-sqrt(k0**2-sqrt(zkt**2-1))
 if(le(5)>zkt)                   q2m=k+sqrt(k0**2-sqrt(zkt**2-1))
                                 q3m=k+sqrt(k0**2+sqrt(zkt**2-1))


 q3mbis=rtsafe(soleC,(/-1.0_qp,1.0_qp/),k+k0,1.e18_qp,1.e-18_qp)
 q3m=min(q3m,q3mbis)

 if(le(1)>zkt) q1p=-k+sqrt(k0**2-sqrt(zkt**2-1))
 q2p=-k+sqrt(k0**2+sqrt(zkt**2-1))

 q2pbis=rtsafe(soleC,(/ 1.0_qp,1.0_qp/),k0-k,1.e18_qp,1.e-18_qp)
 q2p=min(q2p,q2pbis)

 if(zkt>le(4)) qc=sqrt(k0**2-k**2)

else
 if(zkt>le(1)) q1p=rtsafe(soleC,(/ 1.0_qp,1.0_qp/),0.0_qp,1.e18_qp,1.e-18_qp)
 if(zkt>le(6))then
  q4m=rtsafe(soleC,(/-1.0_qp,1.0_qp/),k+k0  ,1.e18_qp,1.e-18_qp)
  kp=k0+k
 elseif(zkt>le(7))then
  qm=sqrt(4*k0**2+2*sqrt((-1.0_qp + zkt)*(3.0_qp + zkt)))
 endif
 if(k<2*k0)then
  km=k-k0
  if(zkt<le(1)) q1m=k-sqrt(k0**2+sqrt(zkt**2-1))
  if(zkt<le(5)) q2m=k-sqrt(k0**2-sqrt(zkt**2-1))
  if((le(6)>zkt).AND.(zkt>le(4)))then
    qd    =rtsafe(soleC,(/-1.0_qp,-1.0_qp/),k+1.0e-17_qp   ,k+k0    ,1.e-18_qp)
    q3m   =rtsafe(soleC,(/-1.0_qp, 1.0_qp/),k   ,qd     ,1.e-18_qp)
    q3mbis=rtsafe(soleC,(/-1.0_qp, 1.0_qp/),qd ,k+k0    ,1.e-18_qp)
  endif
  if((le(5)>zkt).AND.(zkt>le(6))) q3m=rtsafe(soleC,(/-1.0_qp,1.0_qp/),k ,k+k0    ,1.e-18_qp)
 elseif(k<3*k0)then
  km=k-k0
  if(zkt<le(1)) q1m=k-sqrt(k0**2+sqrt(zkt**2-1))
  if(zkt<le(1)) write(6,*)"top"
  if(zkt<le(6)) q2m=rtsafe(soleC,(/-1.0_qp,1.0_qp/),k-k0 ,k+k0    ,1.e-18_qp)
 else
  if((zkt>le(7)).AND.(le(6)>zkt))then
   q1m=rtsafe(soleC,(/-1.0_qp,1.0_qp/),0.0_qp,k-k0    ,1.e-18_qp)
   q2m=rtsafe(soleC,(/-1.0_qp,1.0_qp/),k-k0  ,k+k0    ,1.e-18_qp)
   km=k-k0
  elseif((zkt>le(6)).AND.(le(1)>zkt))then
   q1m=rtsafe(soleC,(/-1.0_qp,1.0_qp/),0.0_qp,k-k0    ,1.e-18_qp)
   km=k-k0
  elseif((zkt>le(8)).AND.(le(7)>zkt))then
   qd=rtsafe(soleC,(/-1.0_qp,-1.0_qp/),0.0_qp,k-k0    ,1.e-18_qp)
   write(6,*)"qd=",qd
   q1m   =rtsafe(soleC,(/-1.0_qp,1.0_qp/),0.0_qp,qd    ,1.e-18_qp)
   q1mbis=rtsafe(soleC,(/-1.0_qp,1.0_qp/),qd    ,k-k0    ,1.e-18_qp)
  else
   km=k-k0
  endif
 endif
endif
if(bla0) write(6,*)"km,q1m,q2m,q3m,q4m=",km,q1m,q2m,q3m,q4m
if(bla0) write(6,*)"q1mbis,q3mbis=",q1mbis,q3mbis
if(bla0) write(6,*)"kp,q1p,q2p,qc,qm=",kp,q1p,q2p,qc


vecq=(/0.0_qp,q1m,q2m,q3m,q4m,q1p,q2p,kp,km,qm,qc,q1mbis,q3mbis/)
call tri(vecq)
bq=vecq(1:8)


CONTAINS 
  SUBROUTINE soleC(q,arg,x,dx)
  REAL(QP), INTENT(IN) :: q
  REAL(QP), DIMENSION(:), INTENT(IN) :: arg
  REAL(QP), INTENT(OUT) :: x,dx

  REAL(QP) sC,dsC,ddsC
  REAL(QP) dec,ddec,s,derivee
  
  s=arg(1)
  derivee=arg(2)

  sC=zkt+2-ec(q)-epsBCS(k+s*q)
!  write(6,*)"q,sC=",q,sC
  if(q<2*k0)then
   dec =0.0_qp
   ddec=0.0_qp
  else
   dec = deps(q/2)
   ddec=ddeps(q/2)/2
  endif
  dsC  =-dec -s   * deps(k+s*q)
  ddsC =-ddec-s**2*ddeps(k+s*q)
  if(derivee>0.0_qp)then
   x=sC
   dx=dsC
  else
!   write(6,*)"q,dsC=",q,dsC
   x=dsc
   dx=ddsc
  endif  
  END SUBROUTINE soleC
END SUBROUTINE bornesq
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SUBROUTINE bornesom(k,zk,q,grecque,res,bom,tres)
USE recettes
REAL(QP), INTENT(IN) :: k,zk,q
INTEGER, INTENT(IN) :: grecque
INTEGER, INTENT(OUT) :: res(1:2),tres
REAL(QP), INTENT(OUT) :: bom(1:3)
REAL(QP) s

bom(:)=1.e100_qp

if(grecque<6)then 
 s=+1.0_qp
else
 s=-1.0_qp
endif

res(:)=0
if((grecque==al).OR.(grecque==alti))then
 tres=1
 bom(1)=ec(q)
 res(1)=1
 bom(2)=zk-epsBCS(k-s*q)
elseif((grecque==bet).OR.(grecque==betti))then
 tres=2
 bom(1)=ec(q)
 res(1)=1
 bom(2)=zk-epsBCS(k-s*q)
 res(2)=2
 bom(3)=zk-1.0_qp
elseif(grecque==gam)then
 tres=1
 bom(1)=ec(q)
 res(1)=2
 bom(2)=zk-1.0_qp
elseif((grecque==delt).OR.(grecque==deltti))then
 tres=1
 bom(1)=zk-epsBCS(k+s*q)
 res(1)=1
 bom(2)=zk-epsBCS(k-s*q)
elseif((grecque==epsi).OR.(grecque==epsiti))then
 tres=2
 bom(1)=zk-epsBCS(k+s*q)
 res(1)=1
 bom(2)=zk-epsBCS(k-s*q)
 res(2)=2
 bom(3)=zk-1.0_qp
elseif(grecque==0)then
 tres=0
endif

END SUBROUTINE bornesom
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FUNCTION ec(q)

REAL(QP), INTENT(IN) :: q
REAL(QP) ec

if(q<2*k0)then
 ec=2.0_qp
else
 ec=2*sqrt(1+(q**2/4-x0)**2)
endif

END FUNCTION ec
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FUNCTION xiBCS(k)
REAL(QP), INTENT(IN) :: k
REAL(QP) xiBCS

xiBCS=k**2-x0
END FUNCTION xiBCS
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FUNCTION deps(k)
REAL(QP), INTENT(IN) :: k
REAL(QP) deps

deps=2*k*xiBCS(k)/epsBCS(k)
END FUNCTION deps
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FUNCTION ddeps(k)
REAL(QP), INTENT(IN) :: k
REAL(QP) ddeps

ddeps=4*k**2/epsBCS(k)**3+4*k**2/epsBCS(k)
END FUNCTION ddeps
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FUNCTION epsBCS(k)
REAL(QP), INTENT(IN) :: k
REAL(QP) epsBCS

epsBCS=sqrt((k**2-x0)**2+1)
END FUNCTION epsBCS
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FUNCTION solom2(k)
USE recettes
REAL(QP), INTENT(IN) :: k
REAL(QP) solom2

REAL(QP) qt

qt=rtsafe(solP,(/bidon/),k0,2*k0,1.0e-19_qp)
solom2=epsBCS(k-2.0_qp*qt)+2.0_qp*epsBCS(qt)-2.0_qp

CONTAINS
 SUBROUTINE solP(qt,arg,P,dP)
 REAL(QP), INTENT(IN) :: qt
 REAL(QP), DIMENSION(:), INTENT(IN) :: arg
 REAL(QP), INTENT(OUT) :: P,dP

 P=    (k**2 - k0**2)**2*(1 + k0**4) - 8*k*(k - k0)*(k + k0)*(1 + k0**4)*qt + &
       (-2*k**4*k0**2 + k**2*(25 + 28*k0**4) - 10*(k0**2 + k0**6))*qt**2 + &
       4*k*(-9 + 4*k**2*k0**2 - 12*k0**4)*qt**3 + (21 + k**4 - 50*k**2*k0**2 + 33*k0**4)*qt**4 - &
       8*k*(k**2 - 9*k0**2)*qt**5 + 8*(3*k**2 - 5*k0**2)*qt**6 - 32*k*qt**7 + 16*qt**8

 dP=     2*(-4*k*(k - k0)*(k + k0)*(1 + k0**4) + &
         (-2*k**4*k0**2 + k**2*(25 + 28*k0**4) - 10*(k0**2 + k0**6))*qt + &
         6*k*(-9 + 4*k**2*k0**2 - 12*k0**4)*qt**2 + 2*(21 + k**4 - 50*k**2*k0**2 + 33*k0**4)*qt**3 - &
         20*k*(k**2 - 9*k0**2)*qt**4 + 24*(3*k**2 - 5*k0**2)*qt**5 - 112*k*qt**6 + 64*qt**7)

 END SUBROUTINE solP
END FUNCTION solom2
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FUNCTION ecritconfig(tconf,config)
INTEGER, INTENT(IN) :: tconf
INTEGER, DIMENSION(:), INTENT(IN) :: config
CHARACTER(len=90) :: ecritconfig

INTEGER itai
if(tconf==0)then
 ecritconfig="0"
 return
endif
ecritconfig=trim(ecritc(config(1)))
do itai=2,tconf
 ecritconfig=trim(ecritconfig)//"  "//trim(ecritc(config(itai)))
enddo
END FUNCTION ecritconfig
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FUNCTION ecritc(c)
INTEGER, INTENT(IN) :: c
CHARACTER(len=7) :: ecritc
if(c==0)then
 ecritc="0"
elseif(c==1)then
 ecritc="al"
elseif(c==2)then
 ecritc="bet"
elseif(c==3)then
 ecritc="gam"
elseif(c==4)then
 ecritc="delt"
elseif(c==5)then
 ecritc="epsi"
elseif(c==6)then
 ecritc="al_ti"
elseif(c==7)then
 ecritc="bet_ti"
elseif(c==8)then
 ecritc="delt_ti"
elseif(c==9)then
 ecritc="epsi_ti"
endif
END FUNCTION ecritc
END MODULE intldc
