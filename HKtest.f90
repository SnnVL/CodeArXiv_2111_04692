program test
USE modsim
USE recettes
USE dspec
USE vars
USE Zerom
USE intpole
USE intldc
USE bestM
USE eqdetat
IMPLICIT NONE

REAL(QP) om,dom,M(1:2,1:2),dM(1:2,1:2),A(1:6),dMm(1:3),q
COMPLEX(QPC) Mm2(1:6)
REAL(QP) bk(0:12),le(1:8)
REAL(QP) EPSq,EPSom,EPS(1:2)
REAL(QP) :: k,zk,bq(1:3)
CHARACTER(len=90) fichom2(1:2),fichlec(1:2),fichgri(1:2),prefixe,suffixe
COMPLEX(QPC) Gamm(1:2,1:2),Matt(1:2,1:2),MatCat(1:2,1:2),det

REAL(QP) ptq,ptom,ptM(1:3),ptdM(1:3)
INTEGER profondeur

LOGICAL interpol,testpt,testdspec,lecture,ecriture

testpt=.FALSE.
testpt=.TRUE.
testdspec=.TRUE.
testdspec=.FALSE.

!Paramètres physiques
x0=4.0_qp
k=4.1_qp
zk=sqrt((k**2-x0)**2+1)-0.0001_qp
k=2.1_qp
zk=3.4_qp
!k 0 to 3
!zk 1 to 6

!Paramètres de dspec
temperaturenulle=.TRUE.
EPSpp=1.0e-8_qp
x0crit=0.0_qp
bla1=.TRUE.
bla1=.FALSE.
bla2=.TRUE.
bla2=.FALSE.

!Paramètres de estM
blaM=.TRUE.
blaM=.FALSE.
blaerr=.TRUE.
blaerr=.FALSE.
qpetit=0.1_qp/x0
qpetit=0.03_qp
!Fichiers de données
fichgri(1)="BCS_4_2"
fichgri(2)="BCS_4_sup_comb"


!Paramètres de intldc
EPSom=1.0e-5_qp
EPSq =1.0e-3_qp
EPS=(/EPSq,EPSom/)
bla0=.TRUE.
bla00=.FALSE.
bla00=.TRUE.
lecture=.FALSE.
lecture=.TRUE.
ecriture=.TRUE.
ecriture=.FALSE.
bq=(/0.0_qp,10.0_qp,100.0_qp/)
profondeur=5
prefixe="avecbestM"
interpol=.TRUE.
fichom2(1) ="DONNEES/Tom1.dat"
fichom2(2) ="DONNEES/Tom1p.dat"
fichlec(1) ="grille_x04_1.dat"
fichlec(2) ="grille_x04_2.dat"
!a tester, q,om= 
!3.868616681         2.065740474
!3.001119563         4.019856415
!q=0.05 om=2.01035604672572088466101471645589475


!fichgri(1)="BCS_4_sup2"
!fichgri(2)="BCS_4_sup3"
!
!call combineom2(fichgri(1),fichgri(2))
!stop


if(testpt)then
 blaM=.TRUE.
 blaerr=.TRUE.
 call load_data(fichgri(1))
 call loadom2(fichgri(2))
 
 call calcxqjoin
 om= 3.0_qp
 om= 2.00969499921292210131045_qp
 xq=0.05_qp
 xq=0.0499812499999999999999999999999
 om=2.00968917749000663444
 om=2.015
 om=2.01000836809456590498816858862099477
 xq=0.0500_qp
 xq=3.044030018         
 om=3.910104303
 xq=0.098148148148148148148148148148148230
 om=2.037004813211050015212474015981164369636
 call oangpp
 write(6,*)"opp=",opp(1:3)
 
 call estmat_pairfield(om,0.0_qp,det,Matt,Gamm)
 write(6,*)"om,xq,real(Matt(1,1))=",om,xq,real(Matt(1,1))
 write(6,*)"om,xq,real(Matt(2,2))=",om,xq,real(Matt(2,2))
 write(6,*)"om,xq,real(Matt(1,2))=",om,xq,real(Matt(1,2))
 write(6,*)"om,xq,real(Matt(1,1))=",om,xq,imag(Matt(1,1))
 write(6,*)"om,xq,real(Matt(2,2))=",om,xq,imag(Matt(2,2))
 write(6,*)"om,xq,real(Matt(1,2))=",om,xq,imag(Matt(1,2))
 write(6,*)
 write(6,*)"det=",det
 write(6,*)
 
 call mat_pairfield(om,0.0_qp,det,Matt,Gamm)
 write(6,*)"om,xq,real(Matt(1,1))=",om,xq,real(Matt(1,1))
 write(6,*)"om,xq,real(Matt(2,2))=",om,xq,real(Matt(2,2))
 write(6,*)"om,xq,real(Matt(1,2))=",om,xq,real(Matt(1,2))
 write(6,*)"om,xq,real(Matt(1,1))=",om,xq,imag(Matt(1,1))
 write(6,*)"om,xq,real(Matt(2,2))=",om,xq,imag(Matt(2,2))
 write(6,*)"om,xq,real(Matt(1,2))=",om,xq,imag(Matt(1,2))
 write(6,*)
 write(6,*)"det=",det
 write(6,*)
 
 call unload_data
 stop
endif

if(testdspec)then
 bla1=.TRUE.
 bla2=.TRUE.
 bla2=.FALSE.
 
 call calcxqjoin
 xq=0.051_qp
 om=2.01035604672572088466101471645589475_qp
 om=2.01035604672572088466101471645589475
 xq=3.868616681         
 om=2.065740474
 xq=4.237037874         
 om=2.237778973
 call oangpp
 write(6,*)"opp=",opp(1:3)
 
 call mat_pairfield(om,0.0_qp,det,Matt,Gamm)
 write(6,*)"om,xq,real(Matt(1,1))=",om,xq,real(Matt(1,1))
 write(6,*)"om,xq,real(Matt(2,2))=",om,xq,real(Matt(2,2))
 write(6,*)"om,xq,real(Matt(1,2))=",om,xq,real(Matt(1,2))
 write(6,*)"om,xq,real(Matt(1,1))=",om,xq,imag(Matt(1,1))
 write(6,*)"om,xq,real(Matt(2,2))=",om,xq,imag(Matt(2,2))
 write(6,*)"om,xq,real(Matt(1,2))=",om,xq,imag(Matt(1,2))
 write(6,*)
 write(6,*)"det=",det
 write(6,*)
 
 stop
endif

call bornesk(bk)
write(6,*)"bk=",bk
call lignesenergie(k,fichom2,le)
write(6,*)"le=",le
Mm2=intres(k,zk,interpol,EPS,fichgri,bk,le,prefixe)
write(6,*)"Mm2=",Mm2
open(17,file="selfE"//trim(suffixe)//".dat")
 write(17,*)real(Mm2),imag(Mm2)
close(17)

!Mm2=intpasres(k,zk,lecture,ecriture,profondeur,EPS,bq,fichlec,prefixe)
open(17,file="selfE"//trim(suffixe)//".dat")
 write(17,*)real(Mm2),imag(Mm2)
close(17)

stop


!x0=4.0_qp
!q=0.1_qp
!xq=q
!om=16000.1_qp
!call oangpp
!
!!Paramètres de dspec
!temperaturenulle=.TRUE.
!EPSpp=1.0e-8_qp
!x0crit=0.0_qp
!bla1=.TRUE.
!bla1=.FALSE.
!bla2=.TRUE.
!bla2=.FALSE.
!
!!Paramètres de estM
!blaM=.FALSE.
!blaM=.TRUE.
!blaerr=.FALSE.
!blaerr=.TRUE.
!qpetit=0.05_qp/x0
!
!write(6,*)"q,om=",q,om
!write(6,*)"opp=",opp(1:3)
!
!fich="BCS_4_2"
!call load_data(fich)
!est=interpolM_recerr(q,om)
!Matt(1,1)=cmplx(est(1),est(4),kind=qpc)
!Matt(2,2)=cmplx(est(2),est(5),kind=qpc)
!Matt(1,2)=cmplx(est(3),est(6),kind=qpc)
!det=Matt(1,1)*Matt(2,2)-Matt(1,2)**2
!write(6,*)
!write(6,*)"det=",det
!write(6,*)
!call unload_data
!
!call mat_pairfield(om,0.0_qp,det,Matt,Gamm)
!write(6,*)"om,xq,real(Matt(1,1))=",om,xq,real(Matt(1,1))
!write(6,*)"om,xq,real(Matt(2,2))=",om,xq,real(Matt(2,2))
!write(6,*)"om,xq,real(Matt(1,2))=",om,xq,real(Matt(1,2))
!write(6,*)"om,xq,real(Matt(1,1))=",om,xq,imag(Matt(1,1))
!write(6,*)"om,xq,real(Matt(2,2))=",om,xq,imag(Matt(2,2))
!write(6,*)"om,xq,real(Matt(1,2))=",om,xq,imag(Matt(1,2))
!write(6,*)
!write(6,*)"det=",det
!write(6,*)
!
!call mat_pairfield_pttq(om,0.0_qp,det,Matt,Gamm)
!write(6,*)"om,xq,real(Matt(1,1))=",om,xq,real(Matt(1,1))
!write(6,*)"om,xq,real(Matt(2,2))=",om,xq,real(Matt(2,2))
!write(6,*)"om,xq,real(Matt(1,2))=",om,xq,real(Matt(1,2))
!write(6,*)"om,xq,real(Matt(1,1))=",om,xq,imag(Matt(1,1))
!write(6,*)"om,xq,real(Matt(2,2))=",om,xq,imag(Matt(2,2))
!write(6,*)"om,xq,real(Matt(1,2))=",om,xq,imag(Matt(1,2))
!write(6,*)
!write(6,*)"det=",det
!write(6,*)

!k=(k11+k12)/2.
!k=1.5*k12
!write(6,*)"k=",k
!
!zkmax=400.0_qp
!bla0=.TRUE.
!do izk=1,200
! zk=3+izk*(zkmax-1.0_qp)/200
! Mm=intim(k,zk) 
!! if(reg.NE.regvieux)then
!!  write(6,*)
!!  write(6,*)"zk,reg,taille=",zk,reg,taille,ecritconfig(taille,config)
!! endif
!!! call ecritconfig(taille,config)
!! call bornesq(k,zk,taille,bq(1:taille)) 
!! write(6,*)"zk,reg=",real(zk,SP),real(bq(1:taille),SP)
!! regvieux=reg
!enddo
!stop
!
!fichdep="DONNEES/Tom1.dat"
!om=solom2(1.5_qp*k0,"DONNEES/Tom1.dat")
!write(6,*)"om=",om
!
!fichdep="DONNEES/Tom1p.dat"
!om=solom2(3.5_qp*k0,"DONNEES/Tom1p.dat")
!write(6,*)"om=",om
!
!stop
!
!x0=0.860436686125678599999999999999999961_qp
!xq=0.5_qp
!om=0.5_qp
!bla2=.TRUE.
!
!EPSpp=1.0e-8_qp
!EPSrpp=1.0e-10_qp
!EPSpt=1.0e-6_qp
!EPSrpt=1.0e-7_qp
!
!call Zero(om,Mm,dMm)
!
!write(6,*) "om=",om
!stop
!
!fichier="lu"
!A=selfEpole(sqrt(x0),1.0_qp)
!
!k=sqrt(x0)
!xik=k**2.0_qp-x0
!epsk=sqrt(xik**2+1)
!Uk2=(1+xik/epsk)/2
!Vk2=(1-xik/epsk)/2
!write(6,*)"deltaeps=",A(3)/epsk-Uk2*A(1)-Vk2*A(2)
!write(6,*)"deltaeps=",A(6)/epsk-Uk2*A(4)-Vk2*A(5)
!
!stop





end program
