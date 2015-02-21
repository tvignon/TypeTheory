
Require Import total2_paths.

Require Import Systems.Auxiliary.
Require Import Systems.UnicodeNotations.
Require Import Systems.CompCats.
Require Import Systems.cwf.

(* Locally override the notation [ γ ♯ a ], at a higher level,
  to get more informative bracketing when pairing meets composition. *) 
Local Notation "γ # a" := (pairing _ _ _ _ γ a) (at level 75).

Section CompPreCat_of_PreCwF.

Context (C : pre_cwf) (homs_sets : has_homsets C).

Definition comp_precat1_of_precwf : comp_precat1.
Proof.
  exists C.
  unfold comp_precat_structure1.
  exists (type C).
  exists (comp_obj C).  
  exact (fun Γ a Γ' f => a[f]).
Defined.

Definition q_precwf {Γ} (a : type C Γ) {Γ'} (f : Γ' ⇒ Γ)
  : (comp_obj _ Γ' (a[f])) ⇒ (Γ ∙ a).
Proof.
  apply (pairing _ _ _ (Γ' ∙ (a[f])) (π _ ;; f)).
  refine (transportb (term C (Γ' ∙ (a [f])) ) (reindx_type_comp C _ _ a) _).
  apply gen_elem.
Defined.

Definition dpr_q_precwf 
  {c} (a : comp_precat1_of_precwf c)
  {c'} (f : c' ⇒ c)
: (q_precwf a f) ;; (π a) = (π (a[f])) ;; f.
Proof.
  apply pre_cwf_law_1.
Qed.

Lemma rterm_univ {c} {a : C ⟨ c ⟩} {c'} (f : c' ⇒ c)
  : ν (a[f])
   = transportf _ (reindx_type_comp C _ _ _)
       (transportf _ (maponpaths (fun g => a[g]) (dpr_q_precwf a f))
         (transportb _ (reindx_type_comp C _ _ _)
            ((ν a)⟦q_precwf a f⟧))).
Proof.
  symmetry.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0.
    apply maponpaths.
    apply pre_cwf_law_2'.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0. apply transportf_pathscomp0.
  apply (term_typeeq_transport_lemma _ (idpath _)).
  apply term_typeeq_transport_lemma_2.
  apply idpath.
Qed.

Definition dpr_q_pbpairing_precwf_aux
  {c} (a : comp_precat1_of_precwf c)
  {c'} (f : c' ⇒ c)
  {X} (h : X ⇒ c ∙ a) (k : X ⇒ c') (H : h ;; π a = k ;; f)
: C ⟨ X ⊢ (a [f]) [k] ⟩
:= (transportf _ (reindx_type_comp C _ _ _)
      (transportf (fun g => C ⟨ X ⊢ a[g] ⟩) H
        (transportf _ (!reindx_type_comp C _ _ _)
          ((ν a)⟦h⟧)))).

Definition dpr_q_pbpairing_commutes
  {c} (a : comp_precat1_of_precwf c)
  {c'} (f : c' ⇒ c)
  {X} (h : X ⇒ c ∙ a) (k : X ⇒ c') (H : h ;; π a = k ;; f)
  (hk := pairing C c' (a[f]) X k (dpr_q_pbpairing_precwf_aux a f h k H))
: (hk ;; q_precwf a f = h) × (hk ;; π (a[f]) = k).
Proof.
  split. Focus 2. apply pre_cwf_law_1.
  unfold q_precwf.
  eapply pathscomp0. Focus 2.
    apply map_to_comp_as_pair_precwf.
  eapply pathscomp0.
    apply pre_cwf_law_3.
  assert ((k # (dpr_q_pbpairing_precwf_aux a f h k H)) ;; (π (a [f]) ;; f) 
          = h ;; π a) as e1.
    eapply pathscomp0. apply assoc.
    refine (_ @ !H).
    apply (maponpaths (fun g => g ;; f)).
    apply pre_cwf_law_1.
  eapply pathscomp0. apply (pairing_mapeq _ _ e1).
  apply maponpaths.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0. apply maponpaths. refine (! rterm_typeeq _ _ _).
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0. apply maponpaths, pre_cwf_law_2'.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0. apply maponpaths, transportf_rtype_mapeq.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0. apply transportf_pathscomp0.
  refine (maponpaths (fun e => transportf _ e _) _).
  apply pre_cwf_types_isaset.
Qed.

Definition dpr_q_pbpairing_precwf
  {c} (a : comp_precat1_of_precwf c)
  {c'} (f : c' ⇒ c)
  {X} (h : X ⇒ c ∙ a) (k : X ⇒ c') (H : h ;; π a = k ;; f)
: Σ (hk : X ⇒ c' ∙ (a[f])),
    ( hk ;; q_precwf a f = h
    × hk ;; π (a[f]) = k).
Proof.
  exists (pairing C c' (a[f]) X k (dpr_q_pbpairing_precwf_aux a f h k H)).
  apply dpr_q_pbpairing_commutes.
Defined.


Definition dpr_q_pbpairing_precwf_mapunique
  {c} (a : comp_precat1_of_precwf c)
  {c'} (f : c' ⇒ c)
  {X} {h : X ⇒ c ∙ a} {k : X ⇒ c'} (H : h ;; π a = k ;; f)
  (hk : X ⇒ c' ◂ a[f])
  (e2 : hk ;; q_precwf a f = h)
  (e1 : hk ;; π (a[f]) = k)
: hk = pr1 (dpr_q_pbpairing_precwf a f h k H).
Proof.
  eapply pathscomp0.
    symmetry. apply map_to_comp_as_pair_precwf.
  eapply pathscomp0.
    apply (pairing_mapeq _ _ e1 _).
  simpl. apply maponpaths.
  eapply pathscomp0.
    apply maponpaths, maponpaths. 
    apply (@maponpaths (C ⟨ c' ∙ (a[f]) ⊢ a[f][π (a[f])] ⟩) _ (fun t => t ⟦hk⟧)).
    apply rterm_univ.
  eapply pathscomp0.
    apply maponpaths, maponpaths. 
    eapply pathscomp0.
      symmetry. apply rterm_typeeq.
    apply maponpaths.
    eapply pathscomp0.
      symmetry. apply rterm_typeeq.
    apply maponpaths.
    eapply pathscomp0.
      symmetry. apply rterm_typeeq.
    apply maponpaths.
    symmetry. apply reindx_term_comp'.
  apply term_typeeq_transport_lemma.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0.
    apply maponpaths, (rterm_mapeq e2).
  eapply pathscomp0. apply transportf_pathscomp0.
  eapply pathscomp0.
    Focus 2. symmetry. apply transportf_rtype_mapeq.
  repeat apply term_typeeq_transport_lemma. 
  apply term_typeeq_transport_lemma_2.
  apply idpath.
Qed.

Definition dpr_q_pbpairing_precwf_unique
  {c} (a : comp_precat1_of_precwf c)
  {c'} (f : c' ⇒ c)
  {X} (h : X ⇒ c ∙ a) (k : X ⇒ c') (H : h ;; π a = k ;; f)
  (t : Σ hk : X ⇒ c' ◂ a[f],
       (hk ;; q_precwf a f = h) × (hk ;; π (a[f]) = k))
: t = dpr_q_pbpairing_precwf a f h k H.
Proof.
  destruct t as [hk [e2 e1]].
  refine (@total2_paths _ _ (tpair _ hk (tpair _ e2 e1)) _ 
    (dpr_q_pbpairing_precwf_mapunique a f H hk e2 e1) _).
  refine (total2_paths _ _); apply homs_sets.
Qed.

Definition comp_precat_of_precwf : comp_precat.
Proof.
  exists comp_precat1_of_precwf.
  unfold comp_precat_structure2.
  exists (proj_mor C).
  exists @q_precwf.
  exists @dpr_q_precwf.
  unfold isPullback; intros.
  exists (dpr_q_pbpairing_precwf _ _ h k H).
  apply dpr_q_pbpairing_precwf_unique.
Defined.

End CompPreCat_of_PreCwF.
