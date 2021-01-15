program test
USE modsim
USE recettes
USE dspec
USE vars
USE Zerom
USE intpole
USE intldc
USE estM
IMPLICIT NONE

REAL(QP) om,dom,M(1:2,1:2),dM(1:2,1:2),A(1:6),dMm(1:3)
COMPLEX(QPC) Mm(1:3)
REAL(QP) vec(1:2000,1:10000)
REAL(QP) vec2(1:2000,1:10000)
REAL(QP) :: xik,epsk,Uk2,Vk2,k,zk,zkmax,le(1:8),bq(1:10),arr(1:8),don(1:7,1:1000,0:100),don2(1:7,1:1000),est(1:6),dest(1:6)
CHARACTER(len=90) fichdep,fich
CHARACTER(len=2)  reg,regvieux
INTEGER izk,taille,config(1:7),pos(1:8),nn,nn2,ixq,ixqbis,compteur,nxq,iom
COMPLEX(QPC) Gamm(1:2,1:2),Matt(1:2,1:2),MatCat(1:2,1:2),det
COMPLEX(QPC) SigPole(1:6)

REAL(QP) ptq,ptom,ptM(1:3),ptdM(1:3)
INTEGER iq, ik, iz

LOGICAL errtype1,errtype2,interpol
!arr=(/6.0_qp,7.0_qp,4.0_qp,3.0_qp,1.0_qp,2.0_qp,8.0_qp,5.0_qp/)
!write(6,*)"arr=",arr
!call tri_pos_q(arr,pos)
!write(6,*)"arr=",arr
!write(6,*)"pos=",pos

! x0=1.5_qp
fichier="specx0_1.5"
blaPole=.TRUE.

! do ik=1,50
!     do iz=1,50
!         k=ik/10.0_qp
!         zk=1.0_qp+iz/10.0_qp
!         A=selfEpole(k,zk)
!     enddo
! enddo
k=1.1_qp
zk=2.5_qp
SigPole=selfEpole(k,zk)
write(6,*)"Sigma=",SigPole(:)

! EPSpp=1.0e-8_qp
! bla1=.FALSE.
! blaM=.TRUE.
! temperaturenulle=.TRUE.
! x0=4.0_qp

! fich="BCSx04"
! call load_data(fich)
! xq=3.3_qp
! om=2.5_qp
! xq=0.246836093457720227245526778373616163_qp
! om=2.06349219682830205570367348567314184_qp
! om=2.17918908882654135720814517067753354_qp
! !est=interpolM(xq,om,dest,errtype1,errtype2)
! est=interpolM_recerr(xq,om)

! call mat_pairfield(om,0.0_qp,det,Matt,Gamm)
! write(6,*)"om,xq,real(Matt(1,1))=",om,xq,real(Matt(1,1))
! write(6,*)"om,xq,real(Matt(2,2))=",om,xq,real(Matt(2,2))
! write(6,*)"om,xq,real(Matt(1,2))=",om,xq,real(Matt(1,2))
! write(6,*)"om,xq,real(Matt(1,1))=",om,xq,imag(Matt(1,1))
! write(6,*)"om,xq,real(Matt(2,2))=",om,xq,imag(Matt(2,2))
! write(6,*)"om,xq,real(Matt(1,2))=",om,xq,imag(Matt(1,2))

! om=2.06293425788714868770824920288479181_qp
! om=2.07261645140824848581721061871322156_qp
! xq=0.157710325387454304623498228689020666_qp

! call mat_pairfield(om,0.0_qp,det,Matt,Gamm)
! write(6,*)"om,xq,real(Matt(1,1))=",om,xq,real(Matt(1,1))
! write(6,*)"om,xq,real(Matt(2,2))=",om,xq,real(Matt(2,2))
! write(6,*)"om,xq,real(Matt(1,2))=",om,xq,real(Matt(1,2))
! write(6,*)"om,xq,real(Matt(1,1))=",om,xq,imag(Matt(1,1))
! write(6,*)"om,xq,real(Matt(2,2))=",om,xq,imag(Matt(2,2))
! write(6,*)"om,xq,real(Matt(1,2))=",om,xq,imag(Matt(1,2))

! call unload_data

! fichom2 ="DONNEES/Tom1.dat"
! fichom2p="DONNEES/Tom1p.dat"
! k=2.1_qp
! zk=3.4_qp
! x0crit=0.0_qp
! x0=4.0_qp
! bla0=.TRUE.
! bla1=.TRUE.
! bla1=.FALSE.
! bla2=.TRUE.
! bla2=.FALSE.

! EPSpp=1.0e-8_qp
! EPSom=1.0e-5_qp
! EPSq =1.0e-3_qp
! call bornesk
! !call lignesenergie(k)
! !le=(/l1,l2,l3,l4,l5,l6,l7,l8/)
! !call tri_q(le)
! !write(6,FMT="(A30,8G20.10)")"lignes d’énergie=",le
! !write(6,*)
! interpol=.TRUE.
! Mm=intim(k,zk,interpol,fich)
! stop

!
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
