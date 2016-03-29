
(**

 Ahrens, Lumsdaine, Voevodsky, 2015 - 2016

*)

Require Import Systems.Auxiliary.
Require Import Systems.UnicodeNotations.
Require Import UniMath.Foundations.Basics.Sets.
Require Import UniMath.CategoryTheory.limits.pullbacks.
Require Import UniMath.CategoryTheory.limits.more_on_pullbacks.
Require Import UniMath.CategoryTheory.UnicodeNotations.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.whiskering.
Require Import UniMath.CategoryTheory.opp_precat.
Require Import UniMath.CategoryTheory.equivalences.
Require Import UniMath.CategoryTheory.precomp_fully_faithful.
Require Import UniMath.CategoryTheory.rezk_completion.
Require Import Systems.RelUnivStructure.
Require Import Systems.Structures.

Local Notation "[ C , D , hs ]" := (functor_precategory C D hs).

Section fix_category.

Variable C : precategory.
Variable hsC : has_homsets C.

Let RC := Rezk_completion C hsC.
Let hsRC : has_homsets RC := pr2 (pr2 (RC)).

Let hsRCop : has_homsets RC^op := has_homsets_opp hsRC.


Local Notation "'Yo'" := (yoneda _ hsC).
Local Notation "'Yo^-1'" :=  (invweq (weqpair _ (yoneda_fully_faithful _ hsC _ _ ))).

Local Notation "'YoR'" := (yoneda _ hsRC).
Local Notation "'YoR^-1'" :=  (invweq (weqpair _ (yoneda_fully_faithful _ hsRC _ _ ))).

Hypothesis X : relative_universe_structure _ _ Yo.

Let YoR_ff : fully_faithful YoR := yoneda_fully_faithful _ hsRC.

Definition R1 := rel_univ_struct_functor _ _ Yo X _ _ YoR YoR_ff (pr2 RC).

Lemma foo : is_category
                 (functor_precategory RC^op HSET (pr2 is_category_HSET)).
Proof.
  apply is_category_functor_category.
Defined.

Definition R2 :=  R1 foo (Rezk_eta _ _ ).

Check R2.

Definition ext :
 functor (functor_precategory C^op HSET (pr2 is_category_HSET))
              (functor_precategory RC^op HSET (pr2 is_category_HSET)).
Proof.
  simpl.
  set (T:= Rezk_op_adj_equiv C hsC HSET is_category_HSET).
  apply (equivalences.right_adjoint (pr1 T)).
Defined.
Definition R3 := R2 ext.

Check R3.


(* TODO 

Definition foo : (forall c : C, F c ≃ G c) -> iso F G 

Definition bla : (forall c : C, iso (F c) (G c)) -> iso F G


*)


Definition nat_iso_from_pointwise_iso (D E : precategory) (hsE : has_homsets E)
                   (F G : [D, E, hsE])
                   (a : ∀ d, iso ((F : functor _ _) d) ((G : functor _ _) d))
                   (H : is_nat_trans _ _ a)
   : iso F G.
Proof.
  use functor_iso_from_pointwise_iso .
  mkpair.
  intro d. apply a.
  apply H.
  intro d. apply (pr2 (a d)).
Defined.

Lemma iso_from_iso_with_postcomp (D E E' : precategory) hsE hsE' (F G : functor D E) (H : functor E E')
          (Hff : fully_faithful H) : 
          iso (C:=[D, E', hsE']) (functor_composite F H) (functor_composite G H)
          -> iso (C:=[D, E, hsE]) F G.
Proof.
  intro a.
  use nat_iso_from_pointwise_iso.
  - intro d. simpl.
    apply (iso_from_fully_faithful_reflection Hff).
    apply (functor_iso_pointwise_if_iso _ _ _ _ _ a (pr2 a)).
  - abstract (
    simpl; intros d d' f;
    assert (XR := nat_trans_ax (pr1 a : nat_trans _ _ ));
    simpl in XR;
    apply (invmaponpathsweq (weq_from_fully_faithful Hff _ _ ));
    simpl; rewrite functor_comp; rewrite functor_comp;
    assert (XTT:=homotweqinvweq (weq_from_fully_faithful Hff (F d') (G d')  ));
    simpl in *;
    etrans; [apply maponpaths; apply XTT |];
    clear XTT;
    assert (XTT:=homotweqinvweq (weq_from_fully_faithful Hff (F d) (G d)  ));
    simpl in *;
    etrans; [| apply cancel_postcomposition; apply (!XTT _ )];
    apply XR
    ).
Defined.


Definition fi_pointwise : ∀ 
  (x : C)
  (x0 : RC^op)
  ,
   iso (((functor_composite Yo ext) x : functor _ _ ) x0)
       (((functor_composite (Rezk_eta C hsC) YoR) x : functor _ _ ) x0 ).
Proof.
  intros Γ ηΓ'.
  apply hset_equiv_iso.
  
  simpl. cbn. 
    
Abort.


Definition functor_assoc_iso (D1 D2 D3 D4 : precategory) hsD4
     (F : functor D1 D2) (G : functor D2 D3) (H : functor D3 D4) :
  iso (C:=[D1,D4,hsD4]) (functor_composite (functor_composite F G) H)
                        (functor_composite F (functor_composite G H)).
Proof.
  use nat_iso_from_pointwise_iso.
  intro d. apply identity_iso.
  intros x x' f. rewrite id_left. rewrite id_right. apply idpath.
Defined.

Definition functor_comp_id_iso (D1 D2 : precategory) hsD2
     (F : functor D1 D2) :
  iso (C:=[D1,D2,hsD2]) (functor_composite F (functor_identity _ )) F.
Proof.
  use nat_iso_from_pointwise_iso.
  - intro. apply identity_iso.
  - intros x x' f. rewrite id_left. rewrite id_right. apply idpath.
Defined.

Definition functor_precomp_iso (D1 D2 D3 : precategory)  hsD3
    (F : functor D1 D2) (G H : functor D2 D3) :
    iso (C:=[D2,D3,hsD3]) G H ->
    iso (C:=[D1,D3,hsD3]) (functor_composite F G)
                          (functor_composite F H).
Proof.
  intro a.
  use nat_iso_from_pointwise_iso.
  - intro d. apply (functor_iso_pointwise_if_iso _ _ _ _ _ a (pr2 a)).
  - intros x x' f. simpl. apply (nat_trans_ax (pr1 a)).
Defined.

(*
Definition functor_remove_id_iso (D1 D2 D3 : precategory) hsD2
     (F : functor D1 D2) (G : functor D2 D3) (H : functor D3 D2) :
  iso (C:=[D2, D2, hsD2]) (functor_composite G H) (functor_identity _ ) → 
  iso (C:=[D1,D2,hsD2]) (functor_composite F (functor_composite G H))
                        F.
Proof.
  use nat_iso_from_pointwise_iso.
  intro d. apply identity_iso.
  intros x x' f. rewrite id_left. rewrite id_right. apply idpath.
Defined.
*)

Definition fi : iso (C:=[C, preShv RC, functor_category_has_homsets _ _ _ ])
                        (functor_composite Yo ext)
                                  (functor_composite (Rezk_eta C hsC) YoR).
Proof.
  set (T:= @iso_from_fully_faithful_reflection _ _ 
              (pre_composition_functor C^op _ HSET hsRCop has_homsets_HSET (functor_opp (Rezk_eta C hsC)))
      
).
  set (XTT:= pre_comp_rezk_eta_opp_is_fully_faithful C hsC HSET is_category_HSET).
  specialize (T XTT).
  set (XR := iso_from_iso_with_postcomp).
  apply (XR _ _ _ (functor_category_has_homsets _ _ _ )
                  (functor_category_has_homsets _ _ _ )  _ _ _ XTT).
  eapply iso_comp.
     apply functor_assoc_iso.
  eapply iso_comp.
     eapply functor_precomp_iso.
     apply counit_iso_from_adj_equivalence_of_precats.
  eapply iso_comp.
    apply functor_comp_id_iso.
  use nat_iso_from_pointwise_iso.
  - intro d.
    exists (yoneda_functor_precomp' _ _ _ _ _ _ ).
    apply is_iso_yoneda_functor_precomp. apply Rezk_eta_fully_faithful.
  - intros x x' f. simpl. simpl.
 simpl.
simpl.
  unfold pre_composition_functor.
  specialize (T (
  use T.
Abort.    

End fix_category.
