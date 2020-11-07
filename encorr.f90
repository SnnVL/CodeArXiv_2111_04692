PROGRAM encorr
USE dspec
USE intldc
IMPLICIT NONE

REAL(QP) :: k,zk
REAL(QP) sE(1:3)
REAL(QP) dk,dzk
REAL(QP) kmin,kmax,zkmin,zkmax
INTEGER nk,nzk,ik,izk

open(10,file='encorr.inp')
 read(10,*)x0
 read(10,*)kmin
 read(10,*)kmax
 read(10,*)nk
 read(10,*)zkmin
 read(10,*)zkmax
 read(10,*)nzk
 read(10,*)suffixe
 read(10,*)bla0
close(10)


write(6,*)'--------------------'
write(6,*)
write(6,*)'Programme encorr'
write(6,*)
write(6,*)'suffixe=',suffixe
write(6,*)'x0=',x0
write(6,*)'kmin=',kmin
write(6,*)'kmax=',kmax
write(6,*)'nk=',nk
write(6,*)'zkmin=',zkmin
write(6,*)'zkmax=',zkmax
write(6,*)'nzk=',nzk

call system("rm "// "selfE"//suffixe//".dat")
open(14,file="selfE"//suffixe//".dat",POSITION="APPEND")
 write(14,*)"!Valeurs de k,zk et sE (l’autoénergie) pour x0=",x0
close(14)


if(nk==0)then
 dk=0.0
else
 dk=(kmax-kmin)/nk
endif

if(nzk==0)then
 dzk=0.0
else
 dzk=(zkmax-zkmin)/nzk
endif

!precisions for mat_pairfield
EPSpp=1.0e-8_qp
EPSrpp=1.0e-10_qp

!precisions for selfE 
EPSu  =1.0e-9_qp
EPSom =1.0e-6_qp
EPSq  =1.0e-5_qp

temperaturenulle=.TRUE.

lecture =.FALSE.
ecriture=.TRUE.
profondeur=7

do ik=0,nk
 k=kmin+dk*ik
 write(6,*)"k=",k
 do izk=0,nzk
  zk=zkmin+dzk*izk
  write(6,*)"zk=",zk
  sE=selfE(k,zk)

  open(14,file="selfE"//suffixe//".dat",POSITION="APPEND")
   write(14,*)zk,k,sE
  close(14)

 enddo
enddo


END PROGRAM encorr
