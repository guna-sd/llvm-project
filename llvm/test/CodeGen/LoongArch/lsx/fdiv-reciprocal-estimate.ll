; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 4
; RUN: llc --mtriple=loongarch64 --mattr=+lsx,-frecipe < %s | FileCheck %s --check-prefix=FAULT
; RUN: llc --mtriple=loongarch64 --mattr=+lsx,+frecipe < %s | FileCheck %s

define void @fdiv_v4f32(ptr %res, ptr %a0, ptr %a1) nounwind {
; FAULT-LABEL: fdiv_v4f32:
; FAULT:       # %bb.0: # %entry
; FAULT-NEXT:    vld $vr0, $a1, 0
; FAULT-NEXT:    vld $vr1, $a2, 0
; FAULT-NEXT:    vfdiv.s $vr0, $vr0, $vr1
; FAULT-NEXT:    vst $vr0, $a0, 0
; FAULT-NEXT:    ret
;
; CHECK-LABEL: fdiv_v4f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vld	$vr0, $a2, 0
; CHECK-NEXT:    vld	$vr1, $a1, 0
; CHECK-NEXT:    vfrecipe.s	$vr2, $vr0
; CHECK-NEXT:    vfmul.s	$vr3, $vr1, $vr2
; CHECK-NEXT:    vfnmsub.s	$vr0, $vr0, $vr3, $vr1
; CHECK-NEXT:    vfmadd.s	$vr0, $vr2, $vr0, $vr3
; CHECK-NEXT:    vst	$vr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %v0 = load <4 x float>, ptr %a0
  %v1 = load <4 x float>, ptr %a1
  %v2 = fdiv fast <4 x float> %v0, %v1
  store <4 x float> %v2, ptr %res
  ret void
}

define void @fdiv_v2f64(ptr %res, ptr %a0, ptr %a1) nounwind {
; FAULT-LABEL: fdiv_v2f64:
; FAULT:       # %bb.0: # %entry
; FAULT-NEXT:    vld $vr0, $a1, 0
; FAULT-NEXT:    vld $vr1, $a2, 0
; FAULT-NEXT:    vfdiv.d $vr0, $vr0, $vr1
; FAULT-NEXT:    vst $vr0, $a0, 0
; FAULT-NEXT:    ret
;
; CHECK-LABEL: fdiv_v2f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vld	$vr0, $a2, 0
; CHECK-NEXT:    vld	$vr1, $a1, 0
; CHECK-NEXT:    lu52i.d	$a1, $zero, -1025
; CHECK-NEXT:    vreplgr2vr.d	$vr2, $a1
; CHECK-NEXT:    vfrecipe.d	$vr3, $vr0
; CHECK-NEXT:    vfmadd.d	$vr2, $vr0, $vr3, $vr2
; CHECK-NEXT:    vfnmsub.d	$vr2, $vr2, $vr3, $vr3
; CHECK-NEXT:    vfmul.d	$vr3, $vr1, $vr2
; CHECK-NEXT:    vfnmsub.d	$vr0, $vr0, $vr3, $vr1
; CHECK-NEXT:    vfmadd.d	$vr0, $vr2, $vr0, $vr3
; CHECK-NEXT:    vst	$vr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %v0 = load <2 x double>, ptr %a0
  %v1 = load <2 x double>, ptr %a1
  %v2 = fdiv fast <2 x double> %v0, %v1
  store <2 x double> %v2, ptr %res
  ret void
}

;; 1.0 / vec
define void @one_fdiv_v4f32(ptr %res, ptr %a0) nounwind {
; FAULT-LABEL: one_fdiv_v4f32:
; FAULT:       # %bb.0: # %entry
; FAULT-NEXT:    vld $vr0, $a1, 0
; FAULT-NEXT:    vfrecip.s $vr0, $vr0
; FAULT-NEXT:    vst $vr0, $a0, 0
; FAULT-NEXT:    ret
;
; CHECK-LABEL: one_fdiv_v4f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vld	$vr0, $a1, 0
; CHECK-NEXT:    vfrecipe.s	$vr1, $vr0
; CHECK-NEXT:    lu12i.w	$a1, -264192
; CHECK-NEXT:    vreplgr2vr.w	$vr2, $a1
; CHECK-NEXT:    vfmadd.s	$vr0, $vr0, $vr1, $vr2
; CHECK-NEXT:    vfnmsub.s	$vr0, $vr0, $vr1, $vr1
; CHECK-NEXT:    vst	$vr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %v0 = load <4 x float>, ptr %a0
  %div = fdiv fast <4 x float> <float 1.0, float 1.0, float 1.0, float 1.0>, %v0
  store <4 x float> %div, ptr %res
  ret void
}

define void @one_fdiv_v2f64(ptr %res, ptr %a0) nounwind {
; FAULT-LABEL: one_fdiv_v2f64:
; FAULT:       # %bb.0: # %entry
; FAULT-NEXT:    vld $vr0, $a1, 0
; FAULT-NEXT:    vfrecip.d $vr0, $vr0
; FAULT-NEXT:    vst $vr0, $a0, 0
; FAULT-NEXT:    ret
;
; CHECK-LABEL: one_fdiv_v2f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vld	$vr0, $a1, 0
; CHECK-NEXT:    vfrecipe.d	$vr1, $vr0
; CHECK-NEXT:    lu52i.d	$a1, $zero, 1023
; CHECK-NEXT:    vreplgr2vr.d	$vr2, $a1
; CHECK-NEXT:    vfnmsub.d	$vr3, $vr0, $vr1, $vr2
; CHECK-NEXT:    vfmadd.d	$vr1, $vr1, $vr3, $vr1
; CHECK-NEXT:    vfnmsub.d	$vr0, $vr0, $vr1, $vr2
; CHECK-NEXT:    vfmadd.d	$vr0, $vr1, $vr0, $vr1
; CHECK-NEXT:    vst	$vr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %v0 = load <2 x double>, ptr %a0
  %div = fdiv fast <2 x double> <double 1.0, double 1.0>, %v0
  store <2 x double> %div, ptr %res
  ret void
}
