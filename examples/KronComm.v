Require Import Setoid.

From VyZX Require Import CoreData.
From VyZX Require Import CoreRules.
From VyZX Require Import PermutationRules.
Require Import MatrixExampleBase.
Require Import MatrixPermBase.
From ViCaR Require Import CategoryTypeclassCompatibility.
Require Import ExamplesAutomation.

Local Open Scope matrix_scope.

Lemma Msum_transpose : forall n m p f,
  (big_sum (G:=Matrix n m) f p) ⊤ = 
  big_sum (G:=Matrix n m) (fun i => (f i) ⊤) p.
Proof.
  intros.
  rewrite (big_sum_func_distr f transpose); easy.
Qed.



Definition kron_comm p q : Matrix (p*q) (p*q):=
  @make_WF (p*q) (p*q) (fun s t => 
  (* have blocks H_ij, p by q of them, and each is q by p *)
  let i := (s / q)%nat in let j := (t / p)%nat in 
  let k := (s mod q)%nat in let l := (t mod p) in
  (* let k := (s - q * i)%nat in let l := (t - p * t)%nat in *)
  if (i =? l) && (j =? k) then C1 else C0
  (* s/q =? t mod p /\ t/p =? s mod q *)
).

Lemma WF_kron_comm p q : WF_Matrix (kron_comm p q).
Proof. unfold kron_comm; auto with wf_db. Qed.
#[export] Hint Resolve WF_kron_comm : wf_db.

(* Lemma test_kron : kron_comm 2 3 = Matrix.Zero.
Proof.
  apply mat_equiv_eq; unfold kron_comm; auto with wf_db.
  print_LHS_matU. 
*)

Lemma kron_comm_transpose_mat_equiv : forall p q, 
  (kron_comm p q) ⊤ ≡ kron_comm q p.
Proof.
  intros p q.
  intros i j Hi Hj.
  unfold kron_comm, transpose, make_WF.
  rewrite andb_comm, Nat.mul_comm.
  rewrite (andb_comm (_ =? _)).
  easy.
Qed.

Lemma kron_comm_transpose : forall p q, 
  (kron_comm p q) ⊤ = kron_comm q p.
Proof.
  intros p q.
  apply mat_equiv_eq; auto with wf_db.
  1: rewrite Nat.mul_comm; apply WF_kron_comm.
  apply kron_comm_transpose_mat_equiv.
Qed.

Lemma kron_comm_1_r_mat_equiv : forall p, 
  (kron_comm p 1) ≡ Matrix.I p.
Proof.
  intros p.
  intros s t Hs Ht.
  unfold kron_comm.
  unfold make_WF.
  unfold Matrix.I.
  rewrite Nat.mul_1_r, Nat.div_1_r, Nat.mod_1_r, Nat.div_small, Nat.mod_small by lia. 
  bdestructΩ'.
Qed.

Lemma kron_comm_1_r : forall p, 
  (kron_comm p 1) = Matrix.I p.
Proof.
  intros p.
  apply mat_equiv_eq; [|rewrite 1?Nat.mul_1_r|]; auto with wf_db.
  apply kron_comm_1_r_mat_equiv.
Qed.

Lemma kron_comm_1_l_mat_equiv : forall p, 
  (kron_comm 1 p) ≡ Matrix.I p.
Proof.
  intros p.
  intros s t Hs Ht.
  unfold kron_comm.
  unfold make_WF.
  unfold Matrix.I.
  rewrite Nat.mul_1_l, Nat.div_1_r, Nat.mod_1_r, Nat.div_small, Nat.mod_small by lia. 
  bdestructΩ'.
Qed.

Lemma kron_comm_1_l : forall p, 
  (kron_comm 1 p) = Matrix.I p.
Proof.
  intros p.
  apply mat_equiv_eq; [|rewrite 1?Nat.mul_1_l|]; auto with wf_db.
  apply kron_comm_1_l_mat_equiv.
Qed.

Definition mx_to_vec {n m} (A : Matrix n m) : Vector (n*m) :=
  make_WF (fun i j => A (i mod n)%nat (i / n)%nat
  (* Note: goes columnwise. Rowwise would be:
  make_WF (fun i j => A (i / m)%nat (i mod n)%nat
  *)
).

Lemma WF_mx_to_vec {n m} (A : Matrix n m) : WF_Matrix (mx_to_vec A).
Proof. unfold mx_to_vec; auto with wf_db. Qed.
#[export] Hint Resolve WF_mx_to_vec : wf_db.

(* Compute vec_to_list (mx_to_vec (Matrix.I 2)). *)
From Coq Require Import ZArith.
Ltac Zify.zify_post_hook ::= PreOmega.Z.div_mod_to_equations.

Lemma kron_comm_mx_to_vec_helper : forall i p q, (i < p * q)%nat ->
  (p * (i mod q) + i / q < p * q)%nat.
Proof.
  intros i p q.
  intros Hi.
  assert (i / q < p)%nat by (apply Nat.div_lt_upper_bound; lia).
  destruct p; [lia|];
  destruct q; [lia|].
  enough (S p * (i mod S q) <= S p * q)%nat by lia.
  apply Nat.mul_le_mono; [lia | ].
  pose proof (Nat.mod_upper_bound i (S q) ltac:(easy)).
  lia.
Qed.

Lemma mx_to_vec_additive_mat_equiv {n m} (A B : Matrix n m) :
  mx_to_vec (A .+ B) ≡ mx_to_vec A .+ mx_to_vec B.
Proof.
  intros i j Hi Hj.
  replace j with O by lia; clear dependent j.
  unfold mx_to_vec, make_WF, Mplus.
  bdestructΩ'.
Qed.

Lemma mx_to_vec_additive {n m} (A B : Matrix n m) :
  mx_to_vec (A .+ B) = mx_to_vec A .+ mx_to_vec B.
Proof.
  apply mat_equiv_eq; auto with wf_db.
  apply mx_to_vec_additive_mat_equiv.
Qed.

Lemma if_mult_dist_r (b : bool) (z : C) :
  (if b then C1 else C0) * z = 
  if b then z else C0.
Proof.
  destruct b; lca.
Qed.

Lemma if_mult_dist_l (b : bool) (z : C) :
  z * (if b then C1 else C0) = 
  if b then z else C0.
Proof.
  destruct b; lca.
Qed.

Lemma if_mult_and (b c : bool) :
  (if b then C1 else C0) * (if c then C1 else C0) =
  if (b && c) then C1 else C0.
Proof.
  destruct b; destruct c; lca.
Qed.

Lemma kron_comm_mx_to_vec_mat_equiv : forall p q (A : Matrix p q),
  kron_comm p q × mx_to_vec A ≡ mx_to_vec (A ⊤).
Proof.
  intros p q A.
  intros i j Hi Hj.
  replace j with O by lia; clear dependent j.
  unfold transpose, mx_to_vec, kron_comm, make_WF, Mmult.
  rewrite (Nat.mul_comm q p). 
  replace_bool_lia (i <? p * q) true.
  replace_bool_lia (0 <? 1) true.
  simpl.
  erewrite big_sum_eq_bounded.
  2: {
  intros k Hk.
  rewrite andb_true_r, <- andb_if.
  replace_bool_lia (k <? p * q) true.
  simpl.
  rewrite if_mult_dist_r.
  replace ((i / q =? k mod p) && (k / p =? i mod q)) with 
    (k =? p * (i mod q) + (i/q));
  [reflexivity|]. (* Set this as our new Σ body; NTS the equality we claimed*)
  rewrite eq_iff_eq_true.
  rewrite andb_true_iff, 3!Nat.eqb_eq.
  split.
  - intros ->.
    destruct p; [lia|].
    destruct q; [lia|].
    split.
    + rewrite Nat.add_comm, Nat.mul_comm.
    rewrite Nat.mod_add by easy.
    rewrite Nat.mod_small; [lia|].
    apply Nat.div_lt_upper_bound; lia.
    + rewrite Nat.mul_comm, Nat.div_add_l by easy.
    rewrite Nat.div_small; [lia|].
    apply Nat.div_lt_upper_bound; lia.
  - intros [Hmodp Hdivp].
    rewrite (Nat.div_mod_eq k p).
    lia.
  }
  apply big_sum_unique.
  exists (p * (i mod q) + i / q)%nat; repeat split;
  [apply kron_comm_mx_to_vec_helper; easy | rewrite Nat.eqb_refl | intros; bdestructΩ'simp].
  destruct p; [lia|];
  destruct q; [lia|].
  f_equal.
  - rewrite Nat.add_comm, Nat.mul_comm, Nat.mod_add, Nat.mod_small; try easy.
  apply Nat.div_lt_upper_bound; lia.
  - rewrite Nat.mul_comm, Nat.div_add_l by easy. 
  rewrite Nat.div_small; [lia|].
  apply Nat.div_lt_upper_bound; lia.
Qed.

Lemma kron_comm_mx_to_vec : forall p q (A : Matrix p q),
  kron_comm p q × mx_to_vec A = mx_to_vec (A ⊤).
Proof.
  intros p q A.
  apply mat_equiv_eq; [|rewrite Nat.mul_comm|]; auto with wf_db.
  apply kron_comm_mx_to_vec_mat_equiv.
Qed.

Lemma kron_comm_ei_kron_ei_sum_mat_equiv : forall p q, 
  kron_comm p q ≡
  big_sum (G:=Square (p*q)) (fun i => big_sum (G:=Square (p*q)) (fun j =>
  (@e_i p i ⊗ @e_i q j) × ((@e_i q j ⊗ @e_i p i) ⊤))
   q) p.
Proof.
  intros p q.
  intros i j Hi Hj.
  rewrite Msum_Csum.
  erewrite big_sum_eq_bounded.
  2: {
  intros k Hk.
  rewrite Msum_Csum.
  erewrite big_sum_eq_bounded.
  2: {
  intros l Hl.
  unfold Mmult, kron, transpose, e_i.
  erewrite big_sum_eq_bounded.
  2: {
  intros m Hm.
  (* replace m with O by lia. *)
  rewrite Nat.div_1_r, Nat.mod_1_r.
  replace_bool_lia (m =? 0) true; rewrite 4!andb_true_r.
  rewrite 3!if_mult_and.
  match goal with 
  |- context[if ?b then _ else _] => 
    replace b with ((i =? k * q + l) && (j =? l * p + k))
  end.
  1: reflexivity. (* set our new function *)
  clear dependent m.
  rewrite eq_iff_eq_true, 8!andb_true_iff, 
    6!Nat.eqb_eq, 4!Nat.ltb_lt.
  split.
  - intros [Hieq Hjeq].
    subst i j.
    rewrite 2!Nat.div_add_l, Nat.div_small, Nat.add_0_r by lia.
    rewrite Nat.add_comm, Nat.mod_add, Nat.mod_small, 
    Nat.div_small, Nat.add_0_r by lia.
    rewrite Nat.add_comm, Nat.mod_add, Nat.mod_small by lia.
    easy.
  - intros [[[] []] [[] []]].
    split.
    + rewrite (Nat.div_mod_eq i q) by lia; lia.
    + rewrite (Nat.div_mod_eq j p) by lia; lia.
  }
  simpl; rewrite Cplus_0_l.
  reflexivity.
  }
  apply big_sum_unique.
  exists (i mod q).
  split; [|split].
  - apply Nat.mod_upper_bound; lia.
  - reflexivity.
  - intros l Hl Hnmod.
  bdestructΩ'simp.
  exfalso; apply Hnmod.
  rewrite Nat.add_comm, Nat.mod_add, Nat.mod_small by lia; lia.
  }
  symmetry.
  apply big_sum_unique.
  exists (j mod p).
  repeat split.
  - apply Nat.mod_upper_bound; lia.
  - unfold kron_comm, make_WF.
  replace_bool_lia (i <? p * q) true.
  replace_bool_lia (j <? p * q) true.
  simpl.
  match goal with
  |- (if ?b then _ else _) = (if ?c then _ else _) =>
    enough (H: b = c) by (rewrite H; easy)
  end.
  rewrite eq_iff_eq_true, 2!andb_true_iff, 4!Nat.eqb_eq.
  split.
  + intros [Hieq Hjeq].
    split; [rewrite Hieq | rewrite Hjeq];
    rewrite Hieq, Nat.div_add_l by lia;
    (rewrite Nat.div_small; [lia|]);
    apply Nat.mod_upper_bound; lia.
  + intros [Hidiv Hjdiv].
    rewrite (Nat.div_mod_eq i q) at 1 by lia.
    rewrite (Nat.div_mod_eq j p) at 2 by lia.
    lia.
  - intros k Hk Hkmod.
  bdestructΩ'simp.
  exfalso; apply Hkmod.
  rewrite Nat.add_comm, Nat.mod_add, Nat.mod_small by lia; lia.
Qed.

Lemma kron_comm_ei_kron_ei_sum : forall p q, 
  kron_comm p q = 
  big_sum (G:=Square (p*q)) (fun i => big_sum (G:=Square (p*q)) (fun j =>
  (@e_i p i ⊗ @e_i q j) × ((@e_i q j ⊗ @e_i p i) ⊤))
   q) p.
Proof.
  intros p q.
  apply mat_equiv_eq; auto with wf_db.
  1: apply WF_Msum; intros; apply WF_Msum; intros; 
   rewrite Nat.mul_comm; apply WF_mult;
   auto with wf_db; rewrite Nat.mul_comm;
   auto with wf_db.
  apply kron_comm_ei_kron_ei_sum_mat_equiv.
Qed.

Lemma kron_comm_ei_kron_ei_sum'_mat_equiv : forall p q, 
  kron_comm p q ≡ 
  big_sum (G:=Square (p*q)) (fun ij =>
  let i := (ij / q)%nat in let j := (ij mod q) in
  ((@e_i p i ⊗ @e_i q j) × ((@e_i q j ⊗ @e_i p i) ⊤))) (p*q).
Proof.
  intros p q.
  rewrite kron_comm_ei_kron_ei_sum, big_sum_double_sum, Nat.mul_comm.
  reflexivity.
Qed.

(* TODO: put somewhere sensible *)
Lemma big_sum_mat_equiv_bounded : forall {o p} (f g : nat -> Matrix o p) (n : nat),
  (forall x : nat, (x < n)%nat -> f x ≡ g x) -> big_sum f n ≡ big_sum g n.
Proof.
  intros.
  induction n.
  - easy.
  - simpl.
    rewrite IHn, H; [easy|lia|auto].
Qed.

Lemma kron_comm_Hij_sum_mat_equiv : forall p q,
  kron_comm p q ≡
  big_sum (G:=Square (p*q)) (fun i => big_sum (G:=Square (p*q)) (fun j =>
  @kron p q q p (@e_i p i × ((@e_i q j) ⊤)) 
  ((@Mmult p 1 q (@e_i p i) (((@e_i q j) ⊤))) ⊤)) q) p.
Proof.
  intros p q.
  rewrite kron_comm_ei_kron_ei_sum_mat_equiv.
  apply big_sum_mat_equiv_bounded; intros i Hi.
  apply big_sum_mat_equiv_bounded; intros j Hj.
  rewrite kron_transpose, kron_mixed_product.
  rewrite Mmult_transpose, transpose_involutive.
  easy.
Qed.

Lemma kron_comm_Hij_sum : forall p q,
  kron_comm p q =
  big_sum (G:=Square (p*q)) (fun i => big_sum (G:=Square (p*q)) (fun j =>
  @kron p q q p (@e_i p i × ((@e_i q j) ⊤)) 
  ((@Mmult p 1 q (@e_i p i) (((@e_i q j) ⊤))) ⊤)) q) p.
Proof.
  intros p q.
  apply mat_equiv_eq; [auto with wf_db| | ].
  - apply WF_Msum; intros i Hi.
    apply WF_Msum; intros j Hj.
    apply WF_kron; try lia;
    [| apply WF_transpose];
    auto with wf_db.
  - apply kron_comm_Hij_sum_mat_equiv.
Qed.


Lemma kron_comm_ei_kron_ei_sum' : forall p q, 
  kron_comm p q = 
  big_sum (G:=Square (p*q)) (fun ij =>
  let i := (ij / q)%nat in let j := (ij mod q) in
  ((@e_i p i ⊗ @e_i q j) × ((@e_i q j ⊗ @e_i p i) ⊤))) (p*q).
Proof.
  intros p q.
  rewrite kron_comm_ei_kron_ei_sum, big_sum_double_sum, Nat.mul_comm.
  reflexivity.
Qed.

Local Notation H := (fun i j => e_i i × (e_i j)⊤).

Lemma kron_comm_Hij_sum'_mat_equiv : forall p q,
  kron_comm p q ≡
  big_sum (G:=Square (p*q)) ( fun ij =>
  let i := (ij / q)%nat in let j := (ij mod q) in
  @kron p q q p (H i j) 
  ((H i j) ⊤)) (p*q).
Proof.
  intros p q.
  rewrite kron_comm_Hij_sum_mat_equiv, big_sum_double_sum, Nat.mul_comm.
  easy.
Qed.

Lemma kron_comm_Hij_sum' : forall p q,
  kron_comm p q =
  big_sum (G:=Square (p*q)) ( fun ij =>
  let i := (ij / q)%nat in let j := (ij mod q) in
  @kron p q q p (H i j) 
  ((H i j) ⊤)) (p*q).
Proof.
  intros p q.
  rewrite kron_comm_Hij_sum, big_sum_double_sum, Nat.mul_comm.
  easy.
Qed.


Lemma div_eq_iff : forall a b c, b <> O ->
  (a / b)%nat = c <-> (b * c <= a /\ a < b * (S c))%nat.
Proof.
  intros a b c Hb.
  split.
  intros Hadivb.
  split;
  subst c.
  etransitivity; [
  apply Nat.div_mul_le, Hb |].
  rewrite Nat.mul_comm, Nat.div_mul; easy.
  apply Nat.mul_succ_div_gt, Hb.
  intros [Hge Hlt].
  symmetry.
  apply (Nat.div_unique _ _ _ (a - b*c)); [lia|].
  lia.
Qed.

Lemma kron_e_i_transpose_l : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (o <> O) -> (m <> O) ->
  (@e_i n k)⊤ ⊗ A = (fun i j =>
  if (i <? m) && (j / o =? k) then A i (j - k * o)%nat else 0).
Proof.
  intros k n m o A Hk Ho Hm.
  apply functional_extensionality; intros i;
  apply functional_extensionality; intros j.
  unfold kron, transpose, e_i.
  rewrite if_mult_dist_r.
  bdestruct (i <? m).
  - rewrite (Nat.div_small i m),
    (Nat.mod_small i m), Nat.eqb_refl, andb_true_r, andb_true_l by easy.
    replace ((j / o =? k) && (j / o <? n)) with (j / o =? k) by bdestructΩ'simp.
    bdestruct_one; [|easy].
    rewrite mod_eq_sub; f_equal;
    lia.
  - bdestructΩ'simp.
    rewrite Nat.div_small_iff in *; lia.
Qed.

Lemma kron_e_i_transpose_l_mat_equiv : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (o <> O) -> (m <> O) ->
  (@e_i n k)⊤ ⊗ A ≡ (fun i j =>
  if (i <? m) && (j / o =? k) then A i (j - k * o)%nat else 0).
Proof.
  intros.
  rewrite kron_e_i_transpose_l; easy.
Qed.

Lemma kron_e_i_transpose_l_mat_equiv' : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (@e_i n k)⊤ ⊗ A ≡ (fun i j =>
  if (i <? m) && (j / o =? k) then A i (j - k * o)%nat else 0).
Proof.
  intros.
  destruct m; [|destruct o];
  try (intros i j Hi Hj; lia).
  rewrite kron_e_i_transpose_l; easy.
Qed.

Lemma kron_e_i_l : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (o <> O) -> (m <> O) ->
  (@e_i n k) ⊗ A = (fun i j =>
  if (j <? o) && (i / m =? k) then A (i - k * m)%nat j else 0).
Proof.
  intros k n m o A Hk Ho Hm.
  apply functional_extensionality; intros i;
  apply functional_extensionality; intros j.
  unfold kron, transpose, e_i.
  rewrite if_mult_dist_r.
  bdestruct (j <? o).
  - rewrite (Nat.div_small j o),
    (Nat.mod_small j o), Nat.eqb_refl, andb_true_r, andb_true_l by easy.
    replace ((i / m =? k) && (i / m <? n)) with (i / m =? k) by bdestructΩ'.
    bdestruct_one; [|easy].
    rewrite mod_eq_sub; f_equal;
    lia.
  - bdestructΩ'simp.
    rewrite Nat.div_small_iff in *; lia.
Qed.

Lemma kron_e_i_l_mat_equiv : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (o <> O) -> (m <> O) ->
  (@e_i n k) ⊗ A ≡ (fun i j =>
  if (j <? o) && (i / m =? k) then A (i - k * m)%nat j else 0).
Proof.
  intros.
  rewrite kron_e_i_l; easy.
Qed.

Lemma kron_e_i_l_mat_equiv' : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (@e_i n k) ⊗ A ≡ (fun i j =>
  if (j <? o) && (i / m =? k) then A (i - k * m)%nat j else 0).
Proof.
  intros.
  destruct m; [|destruct o];
  try (intros i j Hi Hj; lia).
  rewrite kron_e_i_l; easy.
Qed.

Lemma kron_e_i_transpose_l' : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (o <> O) -> (m <> O) ->
  (@e_i n k)⊤ ⊗ A = (fun i j =>
  if (i <? m) && (k * o <=? j) && (j <? (S k) * o) then A i (j - k * o)%nat else 0).
Proof.
  intros k n m o A Hk Ho Hm.
  apply functional_extensionality; intros i;
  apply functional_extensionality; intros j.
  unfold kron, transpose, e_i.
  rewrite if_mult_dist_r.
  bdestruct (i <? m).
  - rewrite (Nat.div_small i m), Nat.eqb_refl, andb_true_r, andb_true_l by easy.
  rewrite Nat.mod_small by easy.
  replace ((j / o =? k) && (j / o <? n)) with ((k * o <=? j) && (j <? S k * o)).
  + do 2 bdestruct_one_old; simpl; try easy.
    destruct o; [lia|].
    f_equal.
    rewrite mod_eq_sub, Nat.mul_comm.
    do 2 f_equal.
    rewrite div_eq_iff; lia.
  + rewrite eq_iff_eq_true, 2!andb_true_iff, Nat.eqb_eq, 2!Nat.ltb_lt, Nat.leb_le.
    assert (Hrw: ((j / o)%nat = k /\ (j / o < n)%nat) <-> ((j/o)%nat=k)) by lia;
    rewrite Hrw; clear Hrw.
    symmetry.
    rewrite div_eq_iff by lia.
    lia.
  - replace (i / m =? 0) with false.
  rewrite andb_false_r; easy.
  symmetry.
  rewrite Nat.eqb_neq.
  rewrite Nat.div_small_iff; lia.
Qed.

Lemma kron_e_i_transpose_l'_mat_equiv : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (o <> O) -> (m <> O) ->
  (@e_i n k)⊤ ⊗ A ≡ (fun i j =>
  if (i <? m) && (k * o <=? j) && (j <? (S k) * o) then A i (j - k * o)%nat else 0).
Proof.
  intros.
  rewrite kron_e_i_transpose_l'; easy.
Qed.

Lemma kron_e_i_transpose_l'_mat_equiv' : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (@e_i n k)⊤ ⊗ A ≡ (fun i j =>
  if (i <? m) && (k * o <=? j) && (j <? (S k) * o) then A i (j - k * o)%nat else 0).
Proof.
  intros.
  destruct m; [|destruct o];
  try (intros i j Hi Hj; lia).
  rewrite kron_e_i_transpose_l'; easy.
Qed.

Lemma kron_e_i_l' : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (o <> O) -> (m <> O) ->
  (@e_i n k) ⊗ A = (fun i j =>
  if (j <? o) && (k * m <=? i) && (i <? (S k) * m) then A (i - k * m)%nat j else 0).
Proof.
  intros k n m o A Hk Ho Hm.
  apply functional_extensionality; intros i;
  apply functional_extensionality; intros j.
  unfold kron, e_i.
  rewrite if_mult_dist_r.
  bdestruct (j <? o).
  - rewrite (Nat.div_small j o), Nat.eqb_refl, andb_true_r, andb_true_l by easy.
  rewrite (Nat.mod_small j o) by easy.
  replace ((i / m =? k) && (i / m <? n)) with ((k * m <=? i) && (i <? S k * m)).
  + do 2 bdestruct_one_old; simpl; try easy.
    destruct m; [lia|].
    f_equal.
    rewrite mod_eq_sub, Nat.mul_comm.
    do 2 f_equal.
    rewrite div_eq_iff; lia.
  + rewrite eq_iff_eq_true, 2!andb_true_iff, Nat.eqb_eq, 2!Nat.ltb_lt, Nat.leb_le.
    assert (Hrw: ((i/m)%nat=k/\(i/m<n)%nat) <-> ((i/m)%nat=k)) by lia;
    rewrite Hrw; clear Hrw.
    symmetry.
    rewrite div_eq_iff by lia.
    lia.
  - replace (j / o =? 0) with false.
  rewrite andb_false_r; easy.
  symmetry.
  rewrite Nat.eqb_neq.
  rewrite Nat.div_small_iff; lia.
Qed.

Lemma kron_e_i_l'_mat_equiv : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (o <> O) -> (m <> O) ->
  (@e_i n k) ⊗ A ≡ (fun i j =>
  if (j <? o) && (k * m <=? i) && (i <? (S k) * m) then A (i - k * m)%nat j else 0).
Proof.
  intros.
  rewrite kron_e_i_l'; easy.
Qed.

Lemma kron_e_i_l'_mat_equiv' : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (o <> O) -> (m <> O) ->
  (@e_i n k) ⊗ A ≡ (fun i j =>
  if (j <? o) && (k * m <=? i) && (i <? (S k) * m) then A (i - k * m)%nat j else 0).
Proof.
  intros.
  destruct m; [|destruct o];
  try (intros i j Hi Hj; lia).
  rewrite kron_e_i_l'; easy.
Qed.  

Lemma kron_e_i_r : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (o <> O) -> (m <> O) ->
  A ⊗ (@e_i n k) = (fun i j =>
  if (i mod n =? k) then A (i / n)%nat j else 0).
Proof.
  intros k n m o A Hk Ho Hm.
  apply functional_extensionality; intros i;
  apply functional_extensionality; intros j.
  unfold kron, e_i.
  rewrite if_mult_dist_l, Nat.div_1_r.
  rewrite Nat.mod_1_r, Nat.eqb_refl, andb_true_r.
  replace (i mod n <? n) with true;
  [rewrite andb_true_r; easy |].
  symmetry; rewrite Nat.ltb_lt.
  apply Nat.mod_upper_bound; lia.
Qed.

Lemma kron_e_i_r_mat_equiv : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (o <> O) -> (m <> O) ->
  A ⊗ (@e_i n k) ≡ (fun i j =>
  if (i mod n =? k) then A (i / n)%nat j else 0).
Proof.
  intros.
  rewrite kron_e_i_r; easy.
Qed.

Lemma kron_e_i_r_mat_equiv' : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  A ⊗ (@e_i n k) ≡ (fun i j =>
  if (i mod n =? k) then A (i / n)%nat j else 0).
Proof.
  intros.
  destruct m; [|destruct o];
  try (intros i j Hi Hj; lia).
  rewrite kron_e_i_r; easy.
Qed.

Lemma kron_e_i_transpose_r : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (o <> O) -> (m <> O) ->
  A ⊗ (@e_i n k) ⊤ = (fun i j =>
  if (j mod n =? k) then A i (j / n)%nat else 0).
Proof.
  intros k n m o A Hk Ho Hm.
  apply functional_extensionality; intros i;
  apply functional_extensionality; intros j.
  unfold kron, transpose, e_i.
  rewrite if_mult_dist_l, Nat.div_1_r.
  rewrite Nat.mod_1_r, Nat.eqb_refl, andb_true_r.
  replace (j mod n <? n) with true;
  [rewrite andb_true_r; easy |].
  symmetry; rewrite Nat.ltb_lt.
  apply Nat.mod_upper_bound; lia.
Qed.

Lemma kron_e_i_transpose_r_mat_equiv : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  (o <> O) -> (m <> O) ->
  A ⊗ (@e_i n k) ⊤ ≡ (fun i j =>
  if (j mod n =? k) then A i (j / n)%nat else 0).
Proof.
  intros.
  rewrite kron_e_i_transpose_r; easy.
Qed.

Lemma kron_e_i_transpose_r_mat_equiv' : forall k n m o (A : Matrix m o), (k < n)%nat -> 
  A ⊗ (@e_i n k) ⊤ ≡ (fun i j =>
  if (j mod n =? k) then A i (j / n)%nat else 0).
Proof.
  intros.
  destruct m; [|destruct o];
  try (intros i j Hi Hj; lia).
  rewrite kron_e_i_transpose_r; easy.
Qed.

Lemma ei_kron_I_kron_ei : forall m n k, (k < n)%nat -> m <> O ->
  (@e_i n k) ⊤ ⊗ (Matrix.I m) ⊗ (@e_i n k) =
  (fun i j => if (i mod n =? k) && (j / m =? k)%nat 
  && (i / n =? j - k * m) && (i / n <? m)
  then 1 else 0).
Proof.
  intros m n k Hk Hm.
  apply functional_extensionality; intros i;
  apply functional_extensionality; intros j.
  rewrite kron_e_i_transpose_l by easy.
  rewrite kron_e_i_r; try lia;
  [| rewrite Nat.mul_eq_0; lia].
  unfold Matrix.I.
  rewrite <- 2!andb_if.
  bdestruct_one_old; [
  rewrite 2!andb_true_r, andb_true_l | rewrite 4!andb_false_r; easy
  ].
  easy.
Qed.

Lemma ei_kron_I_kron_ei_mat_equiv : forall m n k, (k < n)%nat -> m <> O ->
  (@e_i n k) ⊤ ⊗ (Matrix.I m) ⊗ (@e_i n k) ≡
  (fun i j => if (i mod n =? k) && (j / m =? k)%nat 
  && (i / n =? j - k * m) && (i / n <? m)
  then 1 else 0).
Proof.
  intros.
  rewrite ei_kron_I_kron_ei; easy.
Qed.

Lemma ei_kron_I_kron_ei_mat_equiv' : forall m n k, (k < n)%nat ->
  (@e_i n k) ⊤ ⊗ (Matrix.I m) ⊗ (@e_i n k) ≡
  (fun i j => if (i mod n =? k) && (j / m =? k)%nat 
  && (i / n =? j - k * m) && (i / n <? m)
  then 1 else 0).
Proof.
  intros.
  destruct m; try (intros i j Hi Hj; lia).
  rewrite ei_kron_I_kron_ei; easy.
Qed.

Lemma kron_comm_kron_form_sum_mat_equiv : forall m n,
  kron_comm m n ≡ big_sum (G:=Square (m*n)) (fun j =>
  (@e_i n j) ⊤ ⊗ (Matrix.I m) ⊗ (@e_i n j)) n.
Proof.
  intros m n.
  intros i j Hi Hj.
  rewrite Msum_Csum.
  erewrite big_sum_eq_bounded.
  2: {
  intros ij Hij.
  rewrite ei_kron_I_kron_ei by lia.
  reflexivity.
  }
  unfold kron_comm, make_WF.
  replace_bool_lia (i <? m * n) true.
  replace_bool_lia (j <? m * n) true.
  simpl.
  replace (i / n <? m) with true by (
  symmetry; rewrite Nat.ltb_lt; apply Nat.div_lt_upper_bound; lia).
  bdestruct_one; [bdestruct_one|]; simpl; symmetry; [
  apply big_sum_unique;
  exists (j / m)%nat;
  split; [ apply Nat.div_lt_upper_bound; lia | ];
  split; [rewrite (Nat.mul_comm (j / m) m), <- mod_eq_sub by lia; bdestructΩ'|];
  intros k Hk Hkne; bdestructΩ'simp
  | |];
  (rewrite big_sum_0; [easy|]; intros k; bdestructΩ'simp).
  pose proof (mod_eq_sub j m); lia.
Qed.

Lemma kron_comm_kron_form_sum : forall m n,
  kron_comm m n = big_sum (G:=Square (m*n)) (fun j =>
  (@e_i n j) ⊤ ⊗ (Matrix.I m) ⊗ (@e_i n j)) n.
Proof.
  intros m n.
  apply mat_equiv_eq; auto with wf_db.
  1: apply WF_Msum; intros; apply WF_kron; auto with wf_db arith.
  apply kron_comm_kron_form_sum_mat_equiv; easy.
Qed.

Lemma kron_comm_kron_form_sum' : forall m n,
  kron_comm m n = big_sum (G:=Square (m*n)) (fun i =>
  (@e_i m i) ⊗ (Matrix.I n) ⊗ (@e_i m i)⊤) m.
Proof.
  intros.
  rewrite <- (kron_comm_transpose n m).
  rewrite (kron_comm_kron_form_sum n m).
  rewrite Msum_transpose.
  apply big_sum_eq_bounded.
  intros k Hk.
  rewrite Nat.mul_1_l.
  pose proof (kron_transpose _ _ _ _ ((@e_i m k) ⊤ ⊗ Matrix.I n) (@e_i m k)) as H;
  rewrite Nat.mul_1_l, Nat.mul_1_r in H;
  rewrite (Nat.mul_comm n m), H in *; clear H.
  pose proof (kron_transpose _ _ _ _ ((@e_i m k) ⊤) (Matrix.I n)) as H;
  rewrite Nat.mul_1_l in H; 
  rewrite H; clear H.
  rewrite transpose_involutive, id_transpose_eq; easy.
Qed.

Lemma kron_comm_kron_form_sum'_mat_equiv : forall m n,
  kron_comm m n ≡ big_sum (G:=Square (m*n)) (fun i =>
  (@e_i m i) ⊗ (Matrix.I n) ⊗ (@e_i m i)⊤) m.
Proof.
  intros.
  rewrite kron_comm_kron_form_sum'; easy.
Qed.

Lemma e_i_dot_is_component_mat_equiv : forall p k (x : Vector p),
  (k < p)%nat -> 
  (@e_i p k) ⊤ × x ≡ x k O .* Matrix.I 1.
Proof.
  intros p k x Hk.
  intros i j Hi Hj;
  replace i with O by lia;
  replace j with O by lia;
  clear i Hi;
  clear j Hj.
  unfold Mmult, transpose, scale, e_i, Matrix.I.
  simpl_bools.
  rewrite Cmult_1_r.
  apply big_sum_unique.
  exists k.
  split; [easy|].
  bdestructΩ'simp.
  rewrite Cmult_1_l.
  split; [easy|].
  intros l Hl Hkl.
  bdestructΩ'simp.
Qed.

Lemma e_i_dot_is_component : forall p k (x : Vector p),
  (k < p)%nat -> WF_Matrix x ->
  (@e_i p k) ⊤ × x = x k O .* Matrix.I 1.
Proof.
  intros p k x Hk HWF.
  apply mat_equiv_eq; auto with wf_db.
  apply e_i_dot_is_component_mat_equiv; easy.
Qed.

Lemma kron_e_i_e_i : forall p q k l,
  (k < p)%nat -> (l < q)%nat -> 
  @e_i q l ⊗ @e_i p k = @e_i (p*q) (l*p + k).
Proof.
  intros p q k l Hk Hl.
  apply functional_extensionality; intro i.
  apply functional_extensionality; intro j.
  unfold kron, e_i.
  rewrite Nat.mod_1_r, Nat.div_1_r.
  rewrite if_mult_and.
  lazymatch goal with
  |- (if ?b then _ else _) = (if ?c then _ else _) =>
  enough (H : b = c) by (rewrite H; easy)
  end.
  rewrite Nat.eqb_refl, andb_true_r.
  destruct (j =? 0); [|rewrite 2!andb_false_r; easy].
  rewrite 2!andb_true_r.
  rewrite eq_iff_eq_true, 4!andb_true_iff, 3!Nat.eqb_eq, 3!Nat.ltb_lt.
  split.
  - intros [[] []].
  rewrite (Nat.div_mod_eq i p).
  split; nia.
  - intros [].
  subst i.
  rewrite Nat.div_add_l, Nat.div_small, Nat.add_0_r,
  Nat.add_comm, Nat.mod_add, Nat.mod_small by lia.
  easy.
Qed.

Lemma kron_e_i_e_i_mat_equiv : forall p q k l,
  (k < p)%nat -> (l < q)%nat -> 
  @e_i q l ⊗ @e_i p k ≡ @e_i (p*q) (l*p + k).
Proof.
  intros p q k l; intros.
  rewrite (kron_e_i_e_i p q); easy.
Qed.

Lemma kron_eq_sum_mat_equiv : forall p q (x : Vector q) (y : Vector p),
  y ⊗ x ≡ big_sum (fun ij =>
  let i := (ij / q)%nat in let j := ij mod q in
  (x j O * y i O) .* (@e_i p i ⊗ @e_i q j)) (p * q).
Proof.
  intros p q x y.
  erewrite big_sum_eq_bounded.
  2: {
  intros ij Hij.
  simpl.
  rewrite (@kron_e_i_e_i q p) by 
    (try apply Nat.mod_upper_bound; try apply Nat.div_lt_upper_bound; lia).
  rewrite (Nat.mul_comm (ij / q) q).
  rewrite <- (Nat.div_mod_eq ij q).
  reflexivity.
  }
  intros i j Hi Hj.
  replace j with O by lia; clear j Hj.
  simpl.
  rewrite Msum_Csum.
  symmetry.
  apply big_sum_unique.
  exists i.
  split; [lia|].
  unfold e_i; split.
  - unfold scale, kron; bdestructΩ'simp.
  - intros j Hj Hij.
    unfold scale, kron; bdestructΩ'simp.
Qed.

Lemma kron_eq_sum : forall p q (x : Vector q) (y : Vector p),
  WF_Matrix x -> WF_Matrix y ->
  y ⊗ x = big_sum (fun ij =>
  let i := (ij / q)%nat in let j := ij mod q in
  (x j O * y i O) .* (@e_i p i ⊗ @e_i q j)) (p * q).
Proof.
  intros p q x y Hwfx Hwfy.
  apply mat_equiv_eq; [| |]; auto with wf_db.
  apply kron_eq_sum_mat_equiv.
Qed.

Lemma kron_comm_commutes_vectors_l_mat_equiv : forall p q (x : Vector q) (y : Vector p),
  kron_comm p q × (x ⊗ y) ≡ (y ⊗ x).
Proof.
  intros p q x y.
  rewrite kron_comm_ei_kron_ei_sum'_mat_equiv, Mmult_Msum_distr_r.
  rewrite (big_sum_mat_equiv_bounded _ 
  (fun k => x (k mod q) 0 * y (k / q) 0 .* (e_i (k / q) ⊗ e_i (k mod q)))%nat);
  [rewrite <- kron_eq_sum_mat_equiv; easy|].
  intros k Hk.
  simpl.
  match goal with 
  |- (?A × ?B) × ?C ≡ _ => 
  assert (Hassoc: (A × B) × C = A × (B × C)) by apply Mmult_assoc
  end.
  simpl in Hassoc.
  rewrite (Nat.mul_comm q p) in *.
  rewrite Hassoc. clear Hassoc.
  pose proof (kron_transpose _ _ _ _ (@e_i q (k mod q)) (@e_i p (k / q))) as Hrw;
  rewrite (Nat.mul_comm q p) in Hrw;
  simpl in Hrw; rewrite Hrw; clear Hrw.
  pose proof (kron_mixed_product ((e_i (k mod q)) ⊤) ((e_i (k / q)) ⊤) x y) as Hrw;
  rewrite (Nat.mul_comm q p) in Hrw;
  simpl in Hrw; rewrite Hrw; clear Hrw.
  rewrite 2!(e_i_dot_is_component_mat_equiv);
  [ | apply Nat.div_lt_upper_bound; lia |
  apply Nat.mod_upper_bound; lia].
  rewrite Mscale_kron_dist_l, Mscale_kron_dist_r, Mscale_assoc.
  rewrite kron_1_l, Mscale_mult_dist_r, Mmult_1_r by auto with wf_db.
  reflexivity.
Qed.

Lemma kron_comm_commutes_vectors_l : forall p q (x : Vector q) (y : Vector p),
  WF_Matrix x -> WF_Matrix y ->
  kron_comm p q × (x ⊗ y) = (y ⊗ x).
Proof.
  intros p q x y Hwfx Hwfy.
  apply mat_equiv_eq; [apply WF_mult; restore_dims| |]; auto with wf_db.
  apply kron_comm_commutes_vectors_l_mat_equiv.
Qed.

Lemma kron_basis_vector_basis_vector : forall p q k l,
  (k < p)%nat -> (l < q)%nat -> 
  basis_vector q l ⊗ basis_vector p k = basis_vector (p*q) (l*p + k).
Proof.
  intros p q k l Hk Hl.
  apply functional_extensionality; intros i.
  apply functional_extensionality; intros j.
  unfold kron, basis_vector.
  rewrite Nat.mod_1_r, Nat.div_1_r, Nat.eqb_refl, andb_true_r, if_mult_and.
  pose proof (Nat.div_mod_eq i p).
  bdestructΩ'simp.
  rewrite Nat.div_add_l, Nat.div_small in * by lia.
  lia.
Qed.

Lemma kron_basis_vector_basis_vector_mat_equiv : forall p q k l,
  (k < p)%nat -> (l < q)%nat -> 
  basis_vector q l ⊗ basis_vector p k ≡ basis_vector (p*q) (l*p + k).
Proof.
  intros.
  rewrite (kron_basis_vector_basis_vector p q); easy.
Qed.

Lemma kron_extensionality_mat_equiv : forall n m s t (A B : Matrix (n*m) (s*t)),
  (forall (x : Vector s) (y :Vector t), 
  A × (x ⊗ y) ≡ B × (x ⊗ y)) ->
  A ≡ B.
Proof.
  intros n m s t A B Hext.
  apply mat_equiv_of_equiv_on_ei.
  intros i Hi.
  
  pose proof (Nat.div_lt_upper_bound i t s ltac:(lia) ltac:(lia)).
  pose proof (Nat.mod_upper_bound i s ltac:(lia)).
  pose proof (Nat.mod_upper_bound i t ltac:(lia)).

  specialize (Hext (@e_i s (i / t)) (@e_i t (i mod t))).
  rewrite (kron_e_i_e_i_mat_equiv t s) in Hext by lia.
  (* simpl in Hext. *)
  rewrite (Nat.mul_comm (i/t) t), <- (Nat.div_mod_eq i t) in Hext.
  rewrite (Nat.mul_comm t s) in Hext. easy.
Qed.

Lemma kron_extensionality : forall n m s t (A B : Matrix (n*m) (s*t)),
  WF_Matrix A -> WF_Matrix B ->
  (forall (x : Vector s) (y :Vector t), 
  WF_Matrix x -> WF_Matrix y ->
  A × (x ⊗ y) = B × (x ⊗ y)) ->
  A = B.
Proof.
  intros n m s t A B HwfA HwfB Hext.
  apply equal_on_basis_vectors_implies_equal; try easy.
  intros i Hi.
  
  pose proof (Nat.div_lt_upper_bound i t s ltac:(lia) ltac:(lia)).
  pose proof (Nat.mod_upper_bound i s ltac:(lia)).
  pose proof (Nat.mod_upper_bound i t ltac:(lia)).

  specialize (Hext (basis_vector s (i / t)) (basis_vector t (i mod t))
  ltac:(apply basis_vector_WF; easy)
  ltac:(apply basis_vector_WF; easy)
  ).
  rewrite (kron_basis_vector_basis_vector t s) in Hext by lia.

  simpl in Hext.
  rewrite (Nat.mul_comm (i/t) t), <- (Nat.div_mod_eq i t) in Hext.
  rewrite (Nat.mul_comm t s) in Hext. easy.
Qed.

Lemma kron_comm_commutes_mat_equiv : forall n s m t 
  (A : Matrix n s) (B : Matrix m t),
  kron_comm m n × (A ⊗ B) × (kron_comm s t) ≡ (B ⊗ A).
Proof.
  intros n s m t A B.
  rewrite (Nat.mul_comm s t).
  apply (kron_extensionality_mat_equiv _ _ t s).
  intros x y.
  (* simpl. *)
  (* Search "assoc" in Matrix. *)
  rewrite (Mmult_assoc (_ × _)).
  rewrite (Nat.mul_comm t s).
  rewrite kron_comm_commutes_vectors_l_mat_equiv.
  rewrite Mmult_assoc, (Nat.mul_comm m n).
  rewrite kron_mixed_product.
  rewrite (Nat.mul_comm n m), kron_comm_commutes_vectors_l_mat_equiv.
  rewrite <- kron_mixed_product.
  rewrite (Nat.mul_comm t s).
  easy.
Qed.

Lemma kron_comm_commutes : forall n s m t 
  (A : Matrix n s) (B : Matrix m t),
  WF_Matrix A -> WF_Matrix B ->
  kron_comm m n × (A ⊗ B) × (kron_comm s t) = (B ⊗ A).
Proof.
  intros n s m t A B HwfA HwfB.
  apply (kron_extensionality _ _ t s); [| 
  apply WF_kron; try easy; lia |].
  rewrite (Nat.mul_comm t s); apply WF_mult; auto with wf_db;
  apply WF_mult; auto with wf_db;
  rewrite Nat.mul_comm; auto with wf_db.
  (* rewrite Nat.mul_comm; apply WF_mult; [rewrite Nat.mul_comm|auto with wf_db];
  apply WF_mult; auto with wf_db; rewrite Nat.mul_comm; auto with wf_db. *)
  intros x y Hwfx Hwfy.
  (* simpl. *)
  (* Search "assoc" in Matrix. *)
  rewrite (Nat.mul_comm s t).
  rewrite (Mmult_assoc (_ × _)).
  rewrite (Nat.mul_comm t s).
  rewrite kron_comm_commutes_vectors_l by easy.
  rewrite Mmult_assoc, (Nat.mul_comm m n).
  rewrite kron_mixed_product.
  rewrite (Nat.mul_comm n m), kron_comm_commutes_vectors_l by (auto with wf_db).
  rewrite <- kron_mixed_product.
  f_equal; lia.
Qed.

Lemma commute_kron_mat_equiv : forall n s m t 
  (A : Matrix n s) (B : Matrix m t),
  (A ⊗ B) ≡ kron_comm n m × (B ⊗ A) × (kron_comm t s).
Proof.
  intros n s m t A B i j Hi Hj. 
  rewrite (kron_comm_commutes_mat_equiv m t n s B A); try easy; lia.
Qed.


Lemma commute_kron : forall n s m t 
  (A : Matrix n s) (B : Matrix m t),
  WF_Matrix A -> WF_Matrix B ->
  (A ⊗ B) = kron_comm n m × (B ⊗ A) × (kron_comm t s).
Proof.
  intros n s m t A B HA HB. 
  rewrite (kron_comm_commutes m t n s B A HB HA); easy.
Qed.

Lemma kron_comm_mul_inv_mat_equiv : forall p q,
  kron_comm p q × kron_comm q p ≡ Matrix.I _.
Proof.
  intros p q.
  intros i j Hi Hj.
  unfold Mmult, kron_comm, make_WF.
  erewrite big_sum_eq_bounded.
  2: {
  intros k Hk.
  rewrite <- 2!andb_if, if_mult_and.
  replace_bool_lia (k <? p * q) true;
  replace_bool_lia (i <? p * q) true;
  replace_bool_lia (j <? q * p) true;
  replace_bool_lia (k <? q * p) true.
  rewrite 2!andb_true_l.
  match goal with |- context[if ?b then _ else _] =>
  replace b with ((i =? j) && (k =? (i mod q) * p + (j/q)))
  end;
  [reflexivity|].
  rewrite eq_iff_eq_true, 4!andb_true_iff, 6!Nat.eqb_eq.
  split.
  - intros [? ?]; subst.
  destruct p; [easy|destruct q;[lia|]].
  assert (j / S q < S p)%nat by (apply Nat.div_lt_upper_bound; lia).
  rewrite Nat.div_add_l, (Nat.div_small (j / (S q))), Nat.add_0_r by easy.
  rewrite Nat.add_comm, Nat.mod_add, Nat.mod_small by easy.
  easy.
  - intros [[Hiqkp Hkpiq] [Hkpjq Hjqkp]].
  split.
  + rewrite (Nat.div_mod_eq i q), (Nat.div_mod_eq j q).
    lia.
  + rewrite (Nat.div_mod_eq k p).
    lia.
  }
  bdestruct (i =? j).
  - subst.
  apply big_sum_unique.
  exists ((j mod q) * p + (j/q))%nat.
  split; [|split].
  + rewrite Nat.mul_comm. apply kron_comm_mx_to_vec_helper; easy.
  + unfold Matrix.I.
    rewrite Nat.eqb_refl; bdestructΩ'simp.
  + intros; bdestructΩ'simp.
  - unfold Matrix.I.
  replace_bool_lia (i =? j) false.
  rewrite andb_false_l.
  rewrite big_sum_0; [easy|].
  intros; rewrite andb_false_l; easy.
Qed.

Lemma kron_comm_mul_inv : forall p q,
  kron_comm p q × kron_comm q p = Matrix.I _.
Proof.
  intros p q.
  apply mat_equiv_eq; auto with wf_db.
  rewrite kron_comm_mul_inv_mat_equiv; easy.
Qed.

Lemma kron_comm_mul_transpose_r_mat_equiv : forall p q,
  kron_comm p q × (kron_comm p q) ⊤ = Matrix.I _.
Proof.
  intros p q.
  rewrite (kron_comm_transpose p q).
  apply kron_comm_mul_inv.
Qed.

Lemma kron_comm_mul_transpose_r : forall p q,
  kron_comm p q × (kron_comm p q) ⊤ = Matrix.I _.
Proof.
  intros p q.
  rewrite (kron_comm_transpose p q).
  apply kron_comm_mul_inv.
Qed.

Lemma kron_comm_mul_transpose_l_mat_equiv : forall p q,
  (kron_comm p q) ⊤ × kron_comm p q = Matrix.I _.
Proof.
  intros p q.
  rewrite <- (kron_comm_transpose q p).
  rewrite (Nat.mul_comm p q).
  rewrite (transpose_involutive _ _ (kron_comm q p)).
  apply kron_comm_mul_transpose_r_mat_equiv.
Qed.

Lemma kron_comm_mul_transpose_l : forall p q,
  (kron_comm p q) ⊤ × kron_comm p q = Matrix.I _.
Proof.
  intros p q.
  rewrite <- (kron_comm_transpose q p).
  rewrite (Nat.mul_comm p q).
  rewrite (transpose_involutive _ _ (kron_comm q p)).
  apply kron_comm_mul_transpose_r.
Qed.



Lemma kron_comm_commutes_l_mat_equiv : forall n s m t 
  (A : Matrix n s) (B : Matrix m t),
  kron_comm m n × (A ⊗ B) ≡ (B ⊗ A) × (kron_comm t s).
Proof.
  intros n s m t A B.
  match goal with |- ?A ≡ ?B =>
    rewrite <- (Mmult_1_r_mat_eq _ _ A), <- (Mmult_1_r_mat_eq _ _ B) 
  end.
  rewrite (Nat.mul_comm t s).
  rewrite <- (kron_comm_mul_transpose_r), <- 2!Mmult_assoc.
  rewrite (kron_comm_commutes_mat_equiv n s m t).
  apply Mmult_simplify_mat_equiv; [|easy].
  rewrite Mmult_assoc.
  (* let rec gen_patt H :=
    match type of H with 
    | ?f ?x => idtac x; uconstr:(gen_patt f -> _)
    | _ => uconstr:(_)
    end
  in 
  let pat := gen_patt (kron_comm_mul_inv_mat_equiv t s) in
  idtac pat;
  match goal with
  | |- [pat] => idtac "match"
  end.
  match type of (kron_comm_mul_inv_mat_equiv t s) with
  | ?f ?x ≡ ?g ?y => idtac f; idtac x; idtac g; idtac y
  end. *)
  (* Mmult_transpose *)
  (* Tactic Notation "my_context_match" open_constr(g) :=
  (* [match] does not support [uconstr], cf COQBUG(https://github.com/coq/coq/issues/9321),
     so we use [open_constr] *)
  (* let g := open_constr:(g) in *)
  (* turning [g] into an [open_constr] creates new evars, so we must
     eventually unify them with the goal *)
  let G := match goal with |- ?G => G end in
  (* We now search for [g] in the goal, and then replace the matching
     subterm with the [open_constr] [g], so that we can unify the
     result with the goal [G] to resolve the new evars we created *)
  match G with
  | context cG[g]
    => let G' := context cG[g] in
       idtac g; idtac G; idtac G'; idtac cG;
       unify G G'
  end.
  Ltac eval_sat lem :=
    let H := fresh "H" in
    specialize lem as H;
    repeat match type of H with
    | forall a : ?A, _ => let x := fresh "x" in evar (x : A);
      let x := eval unfold x in x in
      specialize (H x)
    end. *)
    (* match t with
    | forall a : ?A, _ => let x := fresh "x" in let H := fresh "H" in 
        evar (x : A); specialize (lem x) as H; idtac H;
        let t := eval_sat H in open_constr:(t)
    | ?P => open_constr:(P)
    end. *)
  
  
  (* eval_sat @kron_comm_mul_inv.
  rewrite H.
  match goal with
  | context[open_contr:(pat)] => idtac "hit"
  end.
  let p := getpat @kron_comm in idtac p.
  match goal with 
  |- context[@Mmult ?n ?m ?o (kron_comm ?t' ?s') (kron_comm ?s'' ?t'')] =>
    (* idtac n m o t' s' s'' t''; *)
    replace s'' with s' by lia;
    replace t'' with t' by lia;
    replace n with (t'*s')%nat by lia;
    replace m with (t'*s')%nat by lia;
    replace o with (t'*s')%nat by lia;
    replace (@Mmult n m o (kron_comm t' s') (kron_comm s' t')) 
      with (@Mmult (t'*s') (t'*s') (t'*s') (kron_comm t' s') (kron_comm s' t')) 
      by (f_equal;lia);
    rewrite (kron_comm_mul_inv_mat_equiv t' s')
  end. *)
  (* rewrite Mmult_1_r_mat_eq.  *)

  rewrite (Nat.mul_comm s t), (kron_comm_mul_inv_mat_equiv t s), Mmult_1_r_mat_eq.
  easy.
Qed.

Lemma kron_comm_commutes_l : forall n s m t 
  (A : Matrix n s) (B : Matrix m t),
  WF_Matrix A -> WF_Matrix B ->
  kron_comm m n × (A ⊗ B) = (B ⊗ A) × (kron_comm t s).
Proof.
  intros n s m t A B HwfA HwfB.
  apply mat_equiv_eq; auto with wf_db.
  apply kron_comm_commutes_l_mat_equiv.
Qed.

Lemma kron_comm_commutes_r_mat_equiv : forall n s m t 
  (A : Matrix n s) (B : Matrix m t),
  (A ⊗ B) × kron_comm s t ≡ (kron_comm n m) × (B ⊗ A).
Proof.
  intros.
  rewrite kron_comm_commutes_l_mat_equiv; easy.
Qed.

Lemma kron_comm_commutes_r : forall n s m t 
  (A : Matrix n s) (B : Matrix m t),
  WF_Matrix A -> WF_Matrix B ->
  (A ⊗ B) × kron_comm s t = (kron_comm n m) × (B ⊗ A).
Proof.
  intros n s m t A B HA HB.
  rewrite kron_comm_commutes_l; easy.
Qed.
  


(* Lemma kron_comm_commutes_r : forall n s m t 
  (A : Matrix n s) (B : Matrix m t),
  WF_Matrix A -> WF_Matrix B ->
  kron_comm m n × (A ⊗ B) = (B ⊗ A) × (kron_comm t s).
Proof.
  intros n s m t A B HwfA HwfB.
  match goal with |- ?A = ?B =>
  rewrite <- (Mmult_1_r _ _ A), <- (Mmult_1_r _ _ B)  ; auto with wf_db
  end.
  rewrite (Nat.mul_comm t s).
  rewrite <- (kron_comm_mul_transpose_r), <- 2!Mmult_assoc.
  rewrite (kron_comm_commutes n s m t) by easy.
  apply Mmult_simplify; [|easy].
  rewrite Mmult_assoc.
  rewrite (Nat.mul_comm s t), (kron_comm_mul_inv t s), Mmult_1_r by auto with wf_db.
  easy.
Qed. *)


Lemma vector_eq_basis_comb_mat_equiv : forall n (y : Vector n),
  y ≡ big_sum (G:=Vector n) (fun i => y i O .* @e_i n i) n.
Proof.
  intros n y.
  intros i j Hi Hj.
  replace j with O by lia; clear j Hj.
  symmetry.
  rewrite Msum_Csum.
  apply big_sum_unique.
  exists i.
  repeat split; try easy.
  - unfold ".*", e_i; bdestructΩ'simp.
  - intros l Hl Hnk.
    unfold ".*", e_i; bdestructΩ'simp.
Qed.


Lemma vector_eq_basis_comb : forall n (y : Vector n),
  WF_Matrix y -> 
  y = big_sum (G:=Vector n) (fun i => y i O .* @e_i n i) n.
Proof.
  intros n y Hwfy.
  apply mat_equiv_eq; auto with wf_db.
  apply vector_eq_basis_comb_mat_equiv.
Qed.

(* Lemma kron_vecT_matrix_vec : forall m n o p
  (P : Matrix m o) (y : Vector n) (z : Vector p),
  WF_Matrix y -> WF_Matrix z -> WF_Matrix P ->
  (z⊤) ⊗ P ⊗ y = @Mmult (m*n) (m*n) (o*p) (kron_comm m n) ((y × (z⊤)) ⊗ P).
Proof.
  intros m n o p P y z Hwfy Hwfz HwfP.
  match goal with |- ?A = ?B =>
  rewrite <- (Mmult_1_l _ _ A) ; auto with wf_db
  end.
  rewrite Nat.mul_1_l.
  rewrite <- (kron_comm_mul_transpose_r), Mmult_assoc at 1.
  rewrite Nat.mul_1_r, (Nat.mul_comm o p).
  apply Mmult_simplify; [easy|].
  rewrite kron_comm_kron_form_sum.
  rewrite Msum_transpose.
  rewrite Mmult_Msum_distr_r.
  erewrite big_sum_eq_bounded.
  2: {
  intros k Hk.
  pose proof (kron_transpose _ _ _ _ ((@e_i n k) ⊤ ⊗ Matrix.I m) (@e_i n k)) as H;
  rewrite Nat.mul_1_l, Nat.mul_1_r, (Nat.mul_comm m n) in *;
  rewrite H; clear H.
  pose proof (kron_transpose _ _ _ _ ((@e_i n k) ⊤) (Matrix.I m)) as H;
  rewrite Nat.mul_1_l in *;
  rewrite H; clear H.
  restore_dims.
  rewrite 2!kron_mixed_product.
  rewrite id_transpose_eq, Mmult_1_l by easy.
  rewrite e_i_dot_is_component, transpose_involutive by easy.
  (* rewrite <- Mmult_transpose. *)
  rewrite Mscale_kron_dist_r, <- 2!Mscale_kron_dist_l.
  rewrite kron_1_r.
  rewrite <- Mscale_mult_dist_l.
  reflexivity.
  }
  rewrite <- (kron_Msum_distr_r n _ P).
  rewrite <- (Mmult_Msum_distr_r).
  rewrite <- vector_eq_basis_comb by easy.
  easy.
Qed. 
*)

Lemma kron_vecT_matrix_vec_mat_equiv : forall m n o p
  (P : Matrix m o) (y : Vector n) (z : Vector p),
  (z⊤) ⊗ P ⊗ y ≡ @Mmult (m*n) (m*n) (o*p) (kron_comm m n) ((y × (z⊤)) ⊗ P).
Proof.
  intros m n o p P y z.
  match goal with |- ?A ≡ ?B =>
  rewrite <- (Mmult_1_l_mat_eq _ _ A)
  end.
  rewrite Nat.mul_1_l.
  rewrite <- (kron_comm_mul_transpose_r_mat_equiv), Mmult_assoc at 1.
  rewrite Nat.mul_1_r, (Nat.mul_comm o p).
  apply Mmult_simplify_mat_equiv; [easy|].
  rewrite kron_comm_kron_form_sum_mat_equiv.
  rewrite Msum_transpose.
  rewrite Mmult_Msum_distr_r.
  erewrite (big_sum_mat_equiv_bounded _ _ n).
  2: {
    intros k Hk.
    unshelve (instantiate (1:=_)).
    refine (fun k : nat => y k 0%nat .* e_i k × (z) ⊤ ⊗ P); exact n.
    pose proof (kron_transpose _ _ _ _ ((@e_i n k) ⊤ ⊗ Matrix.I m) (@e_i n k)) as H;
    rewrite Nat.mul_1_l, Nat.mul_1_r, (Nat.mul_comm m n) in *;
    rewrite H; clear H.
    pose proof (kron_transpose _ _ _ _ ((@e_i n k) ⊤) (Matrix.I m)) as H;
    rewrite Nat.mul_1_l in *;
    rewrite H; clear H.
    restore_dims.
    rewrite 2!kron_mixed_product.
    rewrite (id_transpose_eq m).
    rewrite Mscale_mult_dist_l, transpose_involutive.
    rewrite <- (kron_1_r _ _ P) at 2.
    rewrite Mscale_kron_dist_l, <- !Mscale_kron_dist_r.
    match goal with 
    |- (?A ⊗ ?B ⊗ ?C) ≡ _ => pose proof (kron_assoc_mat_equiv A B C) as H
    end;
    rewrite 4!Nat.mul_1_r in H; rewrite H by easy; clear H.
    apply kron_simplify_mat_equiv; [easy|].
    epose proof (Mscale_kron_dist_r _ _ _ _ _ P (Matrix.I 1)) as H;
    rewrite 2Nat.mul_1_r in H;
    rewrite <- H; clear H.
    match goal with
    |- (?A ⊗ ?B) ≡ (?C ⊗ ?D) => pose proof (kron_simplify_mat_equiv A C B D) as H
    end;
    rewrite 2!Nat.mul_1_r in H. apply H.
    - rewrite Mmult_1_l_mat_eq; easy.
    - rewrite (e_i_dot_is_component_mat_equiv); easy.
  }
  rewrite <- (kron_Msum_distr_r n _ P).
  rewrite <- (Mmult_Msum_distr_r).
  rewrite (Nat.mul_comm m n).
  rewrite <- vector_eq_basis_comb_mat_equiv by easy.
  easy.
Qed.

Lemma kron_vecT_matrix_vec : forall m n o p
  (P : Matrix m o) (y : Vector n) (z : Vector p),
  WF_Matrix y -> WF_Matrix z -> WF_Matrix P ->
  (z⊤) ⊗ P ⊗ y = @Mmult (m*n) (m*n) (o*p) (kron_comm m n) ((y × (z⊤)) ⊗ P).
Proof.
  intros m n o p P y z Hwfy Hwfz HwfP.
  apply mat_equiv_eq; 
  [|rewrite ?Nat.mul_1_l, ?Nat.mul_1_r, (Nat.mul_comm o p); apply WF_mult|]; 
  auto with wf_db;
  [apply WF_kron; auto with wf_db; lia|].
  apply kron_vecT_matrix_vec_mat_equiv.
Qed.


Lemma kron_vec_matrix_vecT : forall m n o p
  (Q : Matrix n o) (x : Vector m) (z : Vector p),
  WF_Matrix x -> WF_Matrix z -> WF_Matrix Q ->
  x ⊗ Q ⊗ (z⊤) = @Mmult (m*n) (m*n) (o*p) (kron_comm m n) (Q ⊗ (x × z⊤)).
Proof.
  intros m n o p Q x z Hwfx Hwfz HwfQ.
  match goal with |- ?A = ?B =>
  rewrite <- (Mmult_1_l _ _ A) ; auto with wf_db
  end.
  rewrite Nat.mul_1_r.
  rewrite <- (kron_comm_mul_transpose_r), Mmult_assoc at 1.
  rewrite Nat.mul_1_l.
  apply Mmult_simplify; [easy|].
  rewrite kron_comm_kron_form_sum'.
  rewrite Msum_transpose.
  rewrite Mmult_Msum_distr_r.
  erewrite big_sum_eq_bounded.
  2: {
  intros k Hk.
  pose proof (kron_transpose _ _ _ _ ((@e_i m k) ⊗ Matrix.I n) ((@e_i m k) ⊤)) as H;
  rewrite Nat.mul_1_l, Nat.mul_1_r, (Nat.mul_comm m n) in *;
  rewrite H; clear H.
  pose proof (kron_transpose _ _ _ _ ((@e_i m k)) (Matrix.I n)) as H;
  rewrite Nat.mul_1_l, (Nat.mul_comm m n) in *;
  rewrite H; clear H.
  restore_dims.
  rewrite 2!kron_mixed_product.
  rewrite id_transpose_eq, Mmult_1_l by easy.
  rewrite e_i_dot_is_component, transpose_involutive by easy.
  (* rewrite <- Mmult_transpose. *)
  rewrite 2!Mscale_kron_dist_l, kron_1_l, <-Mscale_kron_dist_r by easy.
  rewrite <- Mscale_mult_dist_l.
  restore_dims.
  reflexivity.
  }
  rewrite <- (kron_Msum_distr_l m _ Q).
  rewrite <- (Mmult_Msum_distr_r).
  rewrite <- vector_eq_basis_comb by easy.
  easy.
Qed.

(* TODO: Relocate *)
Lemma kron_1_l_mat_equiv : forall {n m} (A : Matrix n m),
  Matrix.I 1 ⊗ A ≡ A.
Proof.
  intros n m A.
  intros i j Hi Hj.
  unfold kron, I.
  rewrite 2!Nat.div_small, 2!Nat.mod_small by lia.
  rewrite Cmult_1_l.
  easy.
Qed.

Lemma kron_1_r_mat_equiv : forall {n m} (A : Matrix n m),
  A ⊗ Matrix.I 1 ≡ A.
Proof.
  intros n m A.
  intros i j Hi Hj.
  unfold kron, I.
  rewrite 2!Nat.div_1_r, 2!Nat.mod_1_r by lia.
  rewrite Cmult_1_r.
  easy.
Qed.

Lemma kron_vec_matrix_vecT_mat_equiv : forall m n o p
  (Q : Matrix n o) (x : Vector m) (z : Vector p),
  x ⊗ Q ⊗ (z⊤) ≡ @Mmult (m*n) (m*n) (o*p) (kron_comm m n) (Q ⊗ (x × z⊤)).
Proof.
  intros m n o p Q x z.
  match goal with |- ?A ≡ ?B =>
  rewrite <- (Mmult_1_l_mat_eq _ _ A)
  end.
  rewrite Nat.mul_1_r.
  rewrite <- (kron_comm_mul_transpose_r_mat_equiv), Mmult_assoc at 1.
  rewrite Nat.mul_1_l.
  apply Mmult_simplify_mat_equiv; [easy|].
  rewrite kron_comm_kron_form_sum'.
  rewrite Msum_transpose.
  rewrite Mmult_Msum_distr_r.
  erewrite (big_sum_mat_equiv_bounded).
  2: {
    intros k Hk.
    unshelve (instantiate (1:=(fun k : nat =>
    @kron n o m p Q
      (@Mmult m 1 p (@scale m 1 (x k 0%nat) (@e_i m k))
          (@transpose p 1 z))))).
    pose proof (kron_transpose _ _ _ _ ((@e_i m k) ⊗ Matrix.I n) ((@e_i m k) ⊤)) as H;
    rewrite Nat.mul_1_l, Nat.mul_1_r, (Nat.mul_comm m n) in *;
    rewrite H; clear H.
    pose proof (kron_transpose _ _ _ _ ((@e_i m k)) (Matrix.I n)) as H;
    rewrite Nat.mul_1_l, (Nat.mul_comm m n) in *;
    rewrite H; clear H.
    restore_dims.
    rewrite 2!kron_mixed_product.
    rewrite id_transpose_eq, transpose_involutive.
    rewrite Mscale_mult_dist_l, Mscale_kron_dist_r, <- Mscale_kron_dist_l.
    rewrite 2!(Nat.mul_1_l).
    apply kron_simplify_mat_equiv; [|easy].
    intros i j Hi Hj.
    unfold kron.
    rewrite (Mmult_1_l_mat_eq _ _ Q) by (apply Nat.mod_upper_bound; lia).
    (* revert i j Hi Hj. *)
    rewrite (e_i_dot_is_component_mat_equiv m k x Hk) by (apply Nat.div_lt_upper_bound; lia).
    set (a:= (@kron 1 1 n o ((x k 0%nat .* Matrix.I 1)) Q) i j).
    match goal with 
    |- ?A = _ => change A with a
    end.
    unfold a.
    clear a.
    rewrite Mscale_kron_dist_l.
    unfold scale.
    rewrite kron_1_l_mat_equiv by lia.
    easy.
  }
  rewrite <- (kron_Msum_distr_l m _ Q).
  rewrite <- (Mmult_Msum_distr_r).
  rewrite (Nat.mul_comm m n).
  rewrite <- vector_eq_basis_comb_mat_equiv.
  easy.
Qed.

Lemma kron_comm_triple_cycle_mat : forall m n s t p q (A : Matrix m n)
  (B : Matrix s t) (C : Matrix p q), 
  A ⊗ B ⊗ C ≡ (kron_comm (m*s) p) × (C ⊗ A ⊗ B) × (kron_comm q (t*n)).
Proof.
  intros m n s t p q A B C.
  rewrite (commute_kron_mat_equiv _ _ _ _ (A ⊗ B) C) by auto with wf_db.
  rewrite (Nat.mul_comm n t), (Nat.mul_comm q (t*n)).
  (* replace (q * (t * n))%nat with (t * n * q)%nat by lia. *)
  apply Mmult_simplify_mat_equiv; [|easy].
  apply Mmult_simplify_mat_equiv; [easy|].
  rewrite (Nat.mul_comm t n).
  intros i j Hi Hj;
  rewrite <- (kron_assoc_mat_equiv C A B);
  [easy|lia|lia].
Qed.

Lemma kron_comm_triple_cycle : forall m n s t p q (A : Matrix m n)
  (B : Matrix s t) (C : Matrix p q), WF_Matrix A -> WF_Matrix B -> WF_Matrix C ->
  A ⊗ B ⊗ C = (kron_comm (m*s) p) × (C ⊗ A ⊗ B) × (kron_comm q (t*n)).
Proof.
  intros m n s t p q A B C HA HB HC.
  rewrite (commute_kron _ _ _ _ (A ⊗ B) C) by auto with wf_db.
  rewrite kron_assoc by easy.
  f_equal; try lia; f_equal; lia.
Qed.

Lemma kron_comm_triple_cycle2_mat_equiv : forall m n s t p q (A : Matrix m n)
  (B : Matrix s t) (C : Matrix p q),
  A ⊗ B ⊗ C ≡ (kron_comm m (s*p)) × (B ⊗ C ⊗ A) × (kron_comm (q*t) n).
Proof.
  intros m n s t p q A B C.
  rewrite kron_assoc_mat_equiv.
  intros i j Hi Hj.
  rewrite (commute_kron_mat_equiv _ _ _ _ A (B ⊗ C)) by lia.
  f_equal; try lia; f_equal; lia.
Qed.

Lemma kron_comm_triple_cycle2 : forall m n s t p q (A : Matrix m n)
  (B : Matrix s t) (C : Matrix p q), WF_Matrix A -> WF_Matrix B -> WF_Matrix C ->
  A ⊗ B ⊗ C = (kron_comm m (s*p)) × (B ⊗ C ⊗ A) × (kron_comm (q*t) n).
Proof.
  intros m n s t p q A B C HA HB HC.
  rewrite kron_assoc by easy.
  rewrite (commute_kron _ _ _ _ A (B ⊗ C)) by auto with wf_db.
  f_equal; try lia; f_equal; lia.
Qed.





(* #[export] Instance big_sum_mat_equiv_morphism {n m : nat} :
  Proper (pointwise_relation nat (@mat_equiv n m) 
  ==> pointwise_relation nat (@mat_equiv n m))
  (@big_sum (Matrix n m) (M_is_monoid n m)) := big_sum_mat_equiv. *)

(* Instance forall_mat_equiv_morphism {A: Type} {n m : nat} {f g : A -> Matrix m n}:
  pointwise_relation A mat_equiv (fun x => f x) (fun x => f x).

Instance forall_mat_equiv_morphism `{Equivalence A eqA, Equivalence B eqB} :
         Proper ((eqA ==> eqB) ==> list_equiv eqA ==> list_equiv eqB) (@map A B).

Goal (forall_relation (fun n:nat => @mat_equiv m m)) (fun n => Matrix.I m × direct_sum' (@Zero 0 0) (Matrix.I m)) (fun n => Matrix.I m).
setoid_rewrite Mmult_1_l_mat_eq. *)

  
Lemma id_eq_sum_kron_e_is_mat_equiv : forall n, 
  Matrix.I n ≡ big_sum (G:=Square n) (fun i => @e_i n i ⊗ (@e_i n i) ⊤) n.
Proof.
  intros n.
  symmetry.
  intros i j Hi Hj.
  rewrite Msum_Csum.
  erewrite big_sum_eq_bounded.
  2: {
  intros k Hk.
  rewrite kron_e_i_l by lia.
  unfold transpose, e_i.
  rewrite <- andb_if.
  replace_bool_lia (j <? n) true.
  rewrite Nat.div_1_r.
  simpl.
  replace ((i =? k) && ((j =? k) && true && (i - k * 1 =? 0)))%nat 
    with ((i =? k) && (j =? k)) by bdestructΩ'.
  reflexivity.
  }
  unfold Matrix.I.
  replace_bool_lia (i <? n) true.
  rewrite andb_true_r.
  bdestruct (i =? j).
  - subst.
  apply big_sum_unique.
  exists j; repeat split; intros; bdestructΩ'.
  - rewrite big_sum_0; [easy|].
  intros k; bdestructΩ'.
Qed.  

Lemma id_eq_sum_kron_e_is : forall n, 
  Matrix.I n = big_sum (G:=Square n) (fun i => @e_i n i ⊗ (@e_i n i) ⊤) n.
Proof.
  intros n.
  apply mat_equiv_eq; auto with wf_db.
  apply id_eq_sum_kron_e_is_mat_equiv.
Qed.

Lemma kron_comm_cycle_indices : forall t s n,
  (kron_comm (t*s) n = @Mmult (s*(n*t)) (s*(n*t)) (t*(s*n)) (kron_comm s (n*t)) (kron_comm t (s*n))).
Proof.
  intros t s n.
  rewrite kron_comm_kron_form_sum.
  erewrite big_sum_eq_bounded.
  2: {
  intros j Hj.
  rewrite (Nat.mul_comm t s), <- id_kron, <- kron_assoc by auto with wf_db.
  restore_dims.
  rewrite kron_assoc by auto with wf_db.
  (* rewrite (kron_assoc ((@e_i n j)⊤ ⊗ Matrix.I t) (Matrix.I s) (@e_i n j)) by auto with wf_db. *)
  lazymatch goal with
  |- ?A ⊗ ?B = _ => rewrite (commute_kron _ _ _ _ A B) by auto with wf_db
  end.
  (* restore_dims. *)
  reflexivity.
  }
  (* rewrite ?Nat.mul_1_r, ?Nat.mul_1_l. *)
  (* rewrite <- Mmult_Msum_distr_r. *)

  rewrite <- (Mmult_Msum_distr_r n _ (kron_comm (t*1) (n*s))).
  rewrite <- Mmult_Msum_distr_l.
  erewrite big_sum_eq_bounded.
  2: {
  intros j Hj.
  rewrite <- kron_assoc, (kron_assoc (Matrix.I t)) by auto with wf_db.
  restore_dims.
  reflexivity.
  } 
  (* rewrite Nat.mul_1_l *)
  rewrite <- (kron_Msum_distr_r n _ (Matrix.I s)).
  rewrite <- (kron_Msum_distr_l n _ (Matrix.I t)).
  rewrite 2!Nat.mul_1_r, 2!Nat.mul_1_l.
  rewrite <- (id_eq_sum_kron_e_is n).
  rewrite 2!id_kron.
  restore_dims.
  rewrite Mmult_1_r by auto with wf_db.
  rewrite (Nat.mul_comm t n), (Nat.mul_comm n s).
  easy.
Qed.

Lemma kron_comm_cycle_indices_mat_equiv : forall t s n,
  (kron_comm (t*s) n ≡ @Mmult (s*(n*t)) (s*(n*t)) (t*(s*n)) (kron_comm s (n*t)) (kron_comm t (s*n))).
Proof.
  intros t s n.
  rewrite kron_comm_cycle_indices; easy.
Qed.

Lemma kron_comm_cycle_indices_rev : forall t s n,
  @Mmult (s*(n*t)) (s*(n*t)) (t*(s*n)) (kron_comm s (n*t)) (kron_comm t (s*n)) = kron_comm (t*s) n.
Proof.
  intros. 
  rewrite <- kron_comm_cycle_indices.
  easy.
Qed.

Lemma kron_comm_cycle_indices_rev_mat_equiv : forall t s n,
  @Mmult (s*(n*t)) (s*(n*t)) (t*(s*n)) (kron_comm s (n*t)) (kron_comm t (s*n)) ≡ kron_comm (t*s) n.
Proof.
  intros. 
  rewrite <- kron_comm_cycle_indices.
  easy.
Qed.

Lemma kron_comm_triple_id : forall t s n, 
  (kron_comm (t*s) n) × (kron_comm (s*n) t) × (kron_comm (n*t) s) = Matrix.I (t*s*n).
Proof.
  intros t s n.
  rewrite kron_comm_cycle_indices.
  restore_dims.
  rewrite (Mmult_assoc (kron_comm s (n*t))).
  restore_dims.
  rewrite (Nat.mul_comm (s*n) t). (* TODO: Fix kron_comm_mul_inv to have the 
    right dimensions by default (or, better yet, to be ambivalent) *)
  rewrite (kron_comm_mul_inv t (s*n)).
  restore_dims.
  rewrite Mmult_1_r by auto with wf_db.
  rewrite (Nat.mul_comm (n*t) s).
  rewrite (kron_comm_mul_inv).
  f_equal; lia.
Qed.

Lemma kron_comm_triple_id_mat_equiv : forall t s n, 
  (kron_comm (t*s) n) × (kron_comm (s*n) t) × (kron_comm (n*t) s) ≡ Matrix.I (t*s*n).
Proof.
  intros t s n.
  setoid_rewrite kron_comm_triple_id; easy.
Qed.

Lemma kron_comm_triple_id' : forall n t s, 
  (kron_comm n (t*s)) × (kron_comm t (s*n)) × (kron_comm s (n*t)) = Matrix.I (t*s*n).
Proof.
  intros n t s.
  (* rewrite kron_comm_cycle_indices. *)
  apply transpose_matrices.

  rewrite 2!Mmult_transpose.
  (* restore_dims. *)
  rewrite (kron_comm_transpose s (n*t)).
  (* restore_dims. *)
  rewrite (kron_comm_transpose n (t*s)).
  restore_dims.
  replace (n*(t*s))%nat with (t*(s*n))%nat by lia.
  replace (s*(n*t))%nat with (t*(s*n))%nat by lia.

  rewrite (kron_comm_transpose t (s*n)).
  (* rewrite <- Mmult_assoc. *)

  (* rewrite (kron_comm_transpose t (s*n)). *)
  restore_dims.
  rewrite Nat.mul_assoc, id_transpose_eq.
  replace (t*s*n)%nat with (t*n*s)%nat by lia.
  rewrite <- (kron_comm_triple_id t n s).
  rewrite Mmult_assoc.
  replace (s*t*n)%nat with (t*n*s)%nat by lia.
  replace (n*t*s)%nat with (t*n*s)%nat by lia.
  apply Mmult_simplify; [f_equal; lia|].
  repeat (f_equal; try lia).
Qed.

Lemma kron_comm_triple_id'_mat_equiv : forall t s n, 
  (kron_comm n (t*s)) × (kron_comm t (s*n)) × (kron_comm s (n*t)) = Matrix.I (t*s*n).
Proof.
  intros t s n.
  rewrite kron_comm_triple_id'.
  easy.
Qed.

Lemma kron_comm_triple_id'C : forall n t s, 
  (kron_comm n (s*t)) × (kron_comm t (n*s)) × (kron_comm s (t*n)) = Matrix.I (t*s*n).
Proof.
  intros n t s.
  rewrite (Nat.mul_comm s t), (Nat.mul_comm n s), 
    (Nat.mul_comm t n), kron_comm_triple_id'.
  easy.
Qed.

Lemma kron_comm_triple_id'C_mat_equiv : forall n t s, 
  (kron_comm n (s*t)) × (kron_comm t (n*s)) × (kron_comm s (t*n)) ≡ Matrix.I (t*s*n).
Proof.
  intros n t s.
  rewrite kron_comm_triple_id'C.
  easy.
Qed.

Lemma kron_comm_triple_indices_collapse_mat_equiv : forall s n t, 
  @Mmult (s*(n*t)) (s*(n*t)) (t*(s*n)) (kron_comm s (n*t)) (kron_comm t (s*n))
   ≡ (kron_comm (t*s) n).
Proof.
  intros s n t.
  rewrite <- (Mmult_1_r_mat_eq _ _ (_ × _)).
  replace (t*(s*n))%nat with (n*(t*s))%nat by lia.
  rewrite <- (kron_comm_mul_inv_mat_equiv).
  rewrite <- Mmult_assoc.
  rewrite (kron_comm_triple_id'C s t n).
  replace (t*n*s)%nat with (n*(t*s))%nat by lia.
  replace (s*(n*t))%nat with (t*s*n)%nat by lia.
  replace (n*(t*s))%nat with (t*s*n)%nat by lia.
  rewrite Mmult_1_l_mat_eq.
  easy.
Qed.

Lemma kron_comm_triple_indices_collapse : forall s n t, 
  @Mmult (s*(n*t)) (s*(n*t)) (t*(s*n)) (kron_comm s (n*t)) (kron_comm t (s*n))
   = (kron_comm (t*s) n).
Proof.
  intros s n t.
  apply mat_equiv_eq; auto with wf_db;
  [apply_with_obligations (WF_kron_comm (t*s) n); lia|].
  apply kron_comm_triple_indices_collapse_mat_equiv.
Qed.

Lemma kron_comm_triple_indices_collapse_mat_equivC : forall s n t, 
  @Mmult (s*(t*n)) (s*(t*n)) (t*(n*s)) (kron_comm s (t*n)) (kron_comm t (n*s))
   ≡ (kron_comm (t*s) n).
Proof.
  intros s n t.
  rewrite (Nat.mul_comm t n), (Nat.mul_comm n s).
  rewrite kron_comm_triple_indices_collapse_mat_equiv.
  easy.
Qed.

Lemma kron_comm_triple_indices_collapseC : forall s n t, 
  @Mmult (s*(t*n)) (s*(t*n)) (t*(n*s)) (kron_comm s (t*n)) (kron_comm t (n*s))
   = (kron_comm (t*s) n).
Proof.
  intros s n t.
  apply mat_equiv_eq; auto with wf_db;
  [apply_with_obligations (WF_kron_comm (t*s) n); lia|].
  apply kron_comm_triple_indices_collapse_mat_equivC.
Qed.

(* 
Not sure what this is, or if it's true:
Lemma kron_comm_triple_indices_commute : forall t s n,
  @Mmult (s*t*n) (s*t*n) (t*(s*n)) (kron_comm (s*t) n) (kron_comm t (s*n)) = 
  @Mmult (t*(s*n)) (t*(s*n)) (s*t*n) (kron_comm t (s*n)) (kron_comm (s*t) n). *)
Lemma kron_comm_triple_indices_commute_mat_equiv : forall t s n,
  @Mmult (s*(n*t)) (s*(n*t)) (t*(s*n)) (kron_comm s (n*t)) (kron_comm t (s*n)) ≡
  @Mmult (t*(s*n)) (t*(s*n)) (s*(n*t)) (kron_comm t (s*n)) (kron_comm s (n*t)).
Proof.
  intros t s n.
  rewrite kron_comm_triple_indices_collapse_mat_equiv.
  rewrite (Nat.mul_comm t s).
  rewrite <- (kron_comm_triple_indices_collapseC t n s).
  easy.
Qed.

Lemma kron_comm_triple_indices_commute : forall t s n,
  @Mmult (s*(n*t)) (s*(n*t)) (t*(s*n)) (kron_comm s (n*t)) (kron_comm t (s*n)) =
  @Mmult (t*(s*n)) (t*(s*n)) (s*(n*t)) (kron_comm t (s*n)) (kron_comm s (n*t)).
Proof.
  intros t s n.
  apply mat_equiv_eq; auto with wf_db;
  [replace (s*(n*t))%nat with (t*(s*n))%nat by lia; apply WF_mult;
   auto with wf_db; apply_with_obligations (WF_kron_comm s (n*t)); lia|].
  apply kron_comm_triple_indices_commute_mat_equiv.
Qed.

Lemma kron_comm_triple_indices_commute_mat_equivC : forall t s n,
  @Mmult (s*(t*n)) (s*(t*n)) (t*(n*s)) (kron_comm s (t*n)) (kron_comm t (n*s)) ≡
  @Mmult (t*(s*n)) (t*(s*n)) (s*(n*t)) (kron_comm t (s*n)) (kron_comm s (n*t)).
Proof.
  intros t s n.
  rewrite (Nat.mul_comm t n), (Nat.mul_comm n s).
  apply kron_comm_triple_indices_commute_mat_equiv.
Qed.

Lemma kron_comm_triple_indices_commuteC : forall t s n,
  @Mmult (s*(t*n)) (s*(t*n)) (t*(n*s)) (kron_comm s (t*n)) (kron_comm t (n*s)) =
  @Mmult (t*(s*n)) (t*(s*n)) (s*(n*t)) (kron_comm t (s*n)) (kron_comm s (n*t)).
Proof.
  intros t s n.
  rewrite (Nat.mul_comm t n), (Nat.mul_comm n s).
  apply kron_comm_triple_indices_commute.
Qed.

Lemma kron_comm_kron_of_mult_commute1_mat_equiv : forall m n p q s t
  (A : Matrix m n) (B : Matrix p q) (C : Matrix q s) (D : Matrix n t),
  @mat_equiv (m*p) (s*t) ((kron_comm m p) × ((B × C) ⊗ (A × D))) 
  ((A ⊗ B) × kron_comm n q × (C ⊗ D)).
Proof.
  intros m n p q s t A B C D.
  rewrite <- kron_mixed_product.
  rewrite (Nat.mul_comm p m), <- Mmult_assoc.
  rewrite kron_comm_commutes_r_mat_equiv.
  match goal with (* TODO: Make a lemma *)
  |- ?A ≡ ?B => enough (H : A = B) by (rewrite H; easy)
  end.
  f_equal; lia.
Qed.

Lemma kron_comm_kron_of_mult_commute2_mat_equiv : forall m n p q s t
  (A : Matrix m n) (B : Matrix p q) (C : Matrix q s) (D : Matrix n t),
  ((A ⊗ B) × kron_comm n q × (C ⊗ D)) ≡ (A × D ⊗ (B × C)) × kron_comm t s.
Proof.
  intros m n p q s t A B C D.
  rewrite Mmult_assoc, kron_comm_commutes_l_mat_equiv, <-Mmult_assoc,
  <- kron_mixed_product.
  easy.
Qed.

Lemma kron_comm_kron_of_mult_commute3_mat_equiv : forall m n p q s t
  (A : Matrix m n) (B : Matrix p q) (C : Matrix q s) (D : Matrix n t),
  (A × D ⊗ (B × C)) × kron_comm t s ≡ 
  (Matrix.I m) ⊗ (B × C) × kron_comm m s × (Matrix.I s ⊗ (A × D)).
Proof.
  intros m n p q s t A B C D.
  rewrite <- 2!kron_comm_commutes_l_mat_equiv, Mmult_assoc.
  restore_dims.
  rewrite kron_mixed_product. 
  rewrite (Nat.mul_comm m p), (Nat.mul_comm t s).
  rewrite Mmult_1_r_mat_eq, Mmult_1_l_mat_eq.
  easy.
Qed.

Lemma kron_comm_kron_of_mult_commute4_mat_equiv : forall m n p q s t
  (A : Matrix m n) (B : Matrix p q) (C : Matrix q s) (D : Matrix n t),
  @mat_equiv (m*p) (s*t) 
  ((Matrix.I m) ⊗ (B × C) × kron_comm m s × (Matrix.I s ⊗ (A × D)))
  ((A × D) ⊗ (Matrix.I p) × kron_comm t p × ((B × C) ⊗ Matrix.I t)).
Proof.
  intros m n p q s t A B C D.
  rewrite <- 2!kron_comm_commutes_l_mat_equiv, 2!Mmult_assoc.
  restore_dims.
  rewrite 2!kron_mixed_product. 
  rewrite (Nat.mul_comm m p), 2!Mmult_1_r_mat_eq.
  rewrite 2!Mmult_1_l_mat_eq.
  easy.
Qed.

Lemma trace_mmult_trans : forall m n (A B : Matrix m n),
  trace (A⊤ × B) = Σ (fun j => Σ (fun i => A i j * B i j) m) n.
Proof.
  intros m n A B.
  apply big_sum_eq_bounded.
  intros j Hj.
  apply big_sum_eq_bounded.
  intros i Hi; reflexivity.
Qed.

Lemma trace_mmult_trans' : forall m n (A B : Matrix m n),
  trace (A⊤ × B) = Σ (fun ij => let j := (ij / m)%nat in 
  let i := ij mod m in 
  A i j * B i j) (m*n).
Proof.
  intros m n A B.
  rewrite trace_mmult_trans, big_sum_double_sum.
  reflexivity.
Qed.

Lemma trace_0_l : forall (A : Square 0), 
  trace A = 0.
Proof.
  intros A.
  unfold trace. 
  easy.
Qed.

Lemma trace_0_r : forall n, 
  trace (@Zero n n) = 0.
Proof.
  intros A.
  unfold trace.
  rewrite big_sum_0; easy.
Qed.

Lemma trace_mplus : forall n (A B : Square n),
  trace (A .+ B) = trace A + trace B.
Proof.
  intros n A B.
  induction n.
  - rewrite 3!trace_0_l; lca.
  - unfold trace in *.
    rewrite <- 3!big_sum_extend_r.
    setoid_rewrite (IHn A B).
    lca.
Qed.

Lemma trace_big_sum : forall n k f,
  trace (big_sum (G:=Square n) f k) = Σ (fun x => trace (f x)) k.
Proof.
  intros n k f.
  induction k.
  - rewrite trace_0_r; easy.
  - rewrite <- 2!big_sum_extend_r, <-IHk.
    setoid_rewrite trace_mplus.
    easy.
Qed.

Lemma Hij_decomp_mat_equiv : forall n m (A : Matrix n m), 
  A ≡ big_sum (G:=Matrix n m) (fun ij =>
  let i := (ij/m)%nat in let j := ij mod m in 
  A i j .* H i j) (n*m).
Proof.
  intros n m A.
  intros i j Hi Hj.
  rewrite Msum_Csum.
  symmetry.
  apply big_sum_unique.
  exists (i*m + j)%nat.
  simpl.
  repeat split.
  - nia.
  - rewrite Nat.div_add_l, Nat.div_small, Nat.add_0_r by lia.
    rewrite Nat.add_comm, Nat.mod_add, Nat.mod_small by lia.
    unfold scale, Mmult.
    erewrite big_sum_unique, Cmult_1_r; [easy|].
    exists O; repeat split; auto;
    unfold transpose, e_i;
    intros;
    rewrite !Nat.eqb_refl;
    simpl_bools;
    bdestructΩ'simp.
  - intros ab Hab Habneq.
    unfold scale, Mmult, transpose, e_i.
    simpl.
    rewrite Cplus_0_l.
    simpl_bools.
    bdestructΩ'simp.
    exfalso; apply Habneq.
    symmetry.
    rewrite (Nat.div_mod_eq ab m) at 1 by lia.
    lia.
Qed.

Lemma Mmult_Hij_Hij_mat_equiv : forall n m o i j k l, (j < m)%nat ->
  @Mmult n m o (H i j) (H k l) ≡ (if (j =? k) then H i l else Zero).
Proof.
  intros n m o i j k l Hj.
  intros a b Ha Hb.
  unfold Mmult, transpose, e_i.
  simpl.
  bdestruct (j =? k).
  - subst k.
    rewrite Cplus_0_l.
    bdestruct (a =? i); simpl;
    bdestruct (b =? l); simpl;
    Csimpl. 
    1: simpl_bools;
      replace_bool_lia (a <? n) true;
      replace_bool_lia (b <? o) true;
      rewrite Cmult_1_l;
      apply big_sum_unique;
      exists j; repeat split;
      intros; simpl_bools; bdestructΩ'simp.
    all: rewrite big_sum_0_bounded; [easy|];
      intros k Hk; bdestructΩ'simp.
  - unfold Zero.
    rewrite big_sum_0_bounded; [easy|].
    intros h Hh; simpl_bools; Csimpl.
    rewrite 3!if_mult_and.
    bdestructΩ'simp.
Qed.

Lemma trace_mmult : forall n m (A : Matrix n m) (B : Matrix m n),
  trace (A × B) = dot (mx_to_vec (A⊤)) (mx_to_vec B).
Proof.
  intros n m A B.
  unfold trace.
  Abort. (* TODO: Come back to this, using e_i ⊗ e_i decomp and linearity *)

Lemma Mmult_Hij_l_mat_equiv : forall n m o (A : Matrix m o) i j, 
  (i < n)%nat -> (j < m)%nat ->
  (H i j : Matrix n m) × A ≡ big_sum (G:=Matrix n o)
  (fun kl : nat => A (kl / o)%nat (kl mod o)
   .* (if j =? kl / o then @e_i n i × (@e_i o (kl mod o)) ⊤ else Zero)) (m * o).
Proof.
  intros n m o A i j Hi Hj.
  rewrite (Hij_decomp_mat_equiv _ _ A) at 1.
  rewrite Mmult_Msum_distr_l.
  simpl.
  set (f := fun a b => A a b .* (if j =? a then @e_i n i × (@e_i o (b)) ⊤ else Zero)).
  rewrite (big_sum_mat_equiv_bounded _ (fun kl => f (kl/o)%nat (kl mod o))).
  2:{
    intros kl Hkl.
    rewrite Mscale_mult_dist_r.
    rewrite Mmult_Hij_Hij_mat_equiv by easy.
    easy.
  }
  easy.
Qed.

Lemma Hij_elem : forall n m i j k l,
  ((H i j) : Matrix n m) k l = if (k=?i)&&(l=?j)&&(i<?n)&&(j<?m) then C1 else C0.
Proof.
  intros.
  unfold Mmult, e_i, transpose; simpl.
  simpl_bools.
  rewrite if_mult_and, Cplus_0_l.
  bdestructΩ'simp.
Qed.

Lemma trace_mmult_Hij_transpose_l : forall {n m} (A: Matrix n m) i j, 
  (i < n)%nat -> (j < m)%nat ->
  trace (H i j × (A⊤)) = A i j.
Proof.
  intros n m A i j Hi Hj.
  rewrite (Hij_decomp_mat_equiv _ _ A) at 1.
  rewrite (Msum_transpose n m (n*m)).
  simpl.
  rewrite Mmult_Hij_l_mat_equiv by easy.
  erewrite big_sum_eq_bounded.
  2: {
    intros ij Hij.
    rewrite Msum_Csum.
    erewrite big_sum_eq_bounded.
    2: {
      intros k Hk.
      unfold scale, transpose, Mmult, e_i.
      simpl; rewrite Cplus_0_l.
      rewrite if_mult_and.
      replace (ij / n <? m)%nat with true
        by (symmetry; rewrite Nat.ltb_lt; apply Nat.div_lt_upper_bound; lia).
      replace (ij mod n <? n) with true 
        by (symmetry; rewrite Nat.ltb_lt; apply Nat.mod_upper_bound; lia).
      simpl_bools.
      rewrite if_mult_dist_l.
      reflexivity.
    } 
    reflexivity.
  }
  apply big_sum_unique.
  exists i; split; [lia|split].
  - rewrite Msum_Csum; apply big_sum_unique.
    exists (j*n+i)%nat; split; [nia|split].
    + rewrite Nat.div_add_l, Nat.div_small, Nat.add_0_r, Nat.eqb_refl by lia.
      rewrite Nat.add_comm, Nat.mod_add, Nat.mod_small by lia.
      unfold scale.
      rewrite Hij_elem, Nat.eqb_refl, (proj2 (Nat.ltb_lt _ _) Hi).
      simpl_bools.
      rewrite Cmult_1_r.
      apply big_sum_unique.
      exists (i*m+j)%nat; split; [nia|split];
      try (intros k Hk).
      1: rewrite Nat.div_add_l, Nat.div_small, Nat.add_0_r, Nat.eqb_refl by lia.
      1: rewrite Nat.add_comm, Nat.mod_add, Nat.mod_small, Nat.eqb_refl by lia.
      all: bdestructΩ'simp.
      pose proof (Nat.div_mod_eq k m).
      lia.
    + intros kl Hkl Hklneq.
      bdestructΩ'simp.
      unfold scale.
      rewrite Hij_elem, Nat.eqb_refl, (proj2 (Nat.ltb_lt _ _) Hi).
      simpl_bools.
      replace (i =? kl mod n) with false; simpl_bools; [lca|].
      symmetry.
      rewrite Nat.eqb_neq.
      intros Hmodeq.
      subst i.
      pose proof (Nat.div_mod_eq kl n); lia.
  - intros i' Hi' Hii'.
    rewrite Msum_Csum.
    unfold scale.
    apply big_sum_0_bounded.
    intros kl Hkl.
    unfold e_i, Zero, Mmult.
    simpl.
    bdestruct_one; try lca.
    rewrite Nat.eqb_sym, (proj2 (Nat.eqb_neq i i') Hii'); simpl_bools; lca.
Qed.

Lemma trace_mmult_eq_ptwise : forall {n m} (A : Matrix n m) (B : Matrix m n),
  trace (A×B) = Σ (fun i => Σ (fun j => A i j * B j i) m) n.
Proof.
  reflexivity.
Qed.

Lemma trace_mmult_eq_comm : forall {n m} (A : Matrix n m) (B : Matrix m n),
  trace (A×B) = trace (B×A).
Proof.
  intros n m A B.
  rewrite 2!trace_mmult_eq_ptwise.
  rewrite big_sum_swap_order.
  do 2 (apply big_sum_eq_bounded; intros).
  apply Cmult_comm.
Qed.

Lemma trace_transpose : forall {n} (A : Square n),
  trace (A ⊤) = trace A.
Proof.
  reflexivity.
Qed.

Lemma trace_mmult_transpose_Hij_l : forall {n m} (A: Matrix m n) i j, 
  (i < m)%nat -> (j < n)%nat ->
  trace ((H i j)⊤ × A) = A i j.
Proof.
  intros n m A i j Hi Hj.
  rewrite trace_mmult_eq_comm, <- trace_transpose, 3!Mmult_transpose,
  2!transpose_involutive, trace_mmult_Hij_transpose_l; try easy.
Qed.


Lemma trace_kron : forall {n p} (A : Square n) (B : Square p),
  trace (A ⊗ B) = trace A * trace B.
Proof.
  intros n p A B.
  destruct p;
  [rewrite Nat.mul_0_r, 2!trace_0_l; lca|].
  unfold trace.
  simpl_rewrite big_sum_product; [|easy].
  reflexivity.
Qed.

Lemma trace_kron_comm_kron : forall m n (A B : Matrix m n), 
  trace (kron_comm m n × (A ⊤ ⊗ B)) = trace (A⊤ × B).
Proof.
  intros m n A B.
  rewrite kron_comm_Hij_sum'.
  rewrite Mmult_Msum_distr_r.
  rewrite trace_mmult_trans', trace_big_sum.
  set (f:= fun a b => A a b * B a b).
  erewrite big_sum_eq_bounded.
  2:{
    intros ij Hij.
    simpl.
    rewrite kron_mixed_product' by lia.
    rewrite trace_kron, trace_mmult_Hij_transpose_l by
    (try apply Nat.div_lt_upper_bound; try apply Nat.mod_upper_bound; lia).
    rewrite trace_mmult_transpose_Hij_l by
    (try apply Nat.div_lt_upper_bound; try apply Nat.mod_upper_bound; lia).
    fold (f (ij/n)%nat (ij mod n)).
    reflexivity.
  }
  rewrite (Nat.mul_comm m n), <- (big_sum_double_sum f).
  rewrite big_sum_swap_order.
  rewrite big_sum_double_sum.
  rewrite Nat.mul_comm.
  easy.
Qed.


(* TODO: put a normal place *)
Lemma kron_comm_mx_to_vec_r_mat_equiv : forall p q (A : Matrix p q),
  (mx_to_vec (A ⊤)) ⊤ × kron_comm p q ≡ (mx_to_vec A) ⊤.
Proof.
  intros p q A.
  match goal with 
  |- ?B ≡ ?C => rewrite <- (transpose_involutive _ _ B), <- (transpose_involutive _ _ C)
  end.
  rewrite Nat.mul_comm.
  apply transpose_simplify_mat_equiv.
  rewrite Mmult_transpose.
  rewrite Nat.mul_comm.
  rewrite kron_comm_transpose_mat_equiv.
  rewrite transpose_involutive.
  (* rewrite Nat.mul_comm. *)
  (* restore_dims. *)
  apply_with_obligations (kron_comm_mx_to_vec_mat_equiv q p (A⊤)); 
  [f_equal|]; lia.
Qed.

Lemma trace_mmult_eq_dot_mx_to_vec : forall {m n} (A B : Matrix m n),
  trace (A⊤ × B) = mx_to_vec A ∘ mx_to_vec B.
Proof.
  intros m n A B.
  rewrite trace_mmult_eq_ptwise.
  rewrite big_sum_double_sum.
  unfold dot, mx_to_vec.
  (* rewrite Nat.mul_comm. *)
  apply big_sum_eq_bounded.
  intros ij Hij.
  unfold make_WF.
  replace_bool_lia (ij <? m*n) true.
  reflexivity.
Qed.

Lemma dot_eq_mmult_00 : forall {n} (u v : Vector n),
  u ∘ v = (u⊤ × v) O O.
Proof.
  reflexivity.
Qed.

Lemma trace_transpose_mmult_as_kron_form : forall {m n} (A B : Matrix m n),
  trace (A⊤ × B) = ((mx_to_vec (A⊤))⊤ × kron_comm m n × mx_to_vec B) O O.
Proof. 
  intros m n A B.
  rewrite trace_mmult_eq_dot_mx_to_vec.
  rewrite dot_eq_mmult_00.
  match goal with
  |- ?C O O = ?D O O => enough (C ≡ D) by auto
  end.
  rewrite kron_comm_mx_to_vec_r_mat_equiv.
  easy.
Qed.

Lemma gcd_grow : forall n m,
  Nat.gcd (S n) m = Nat.gcd (m mod S n) (S n).
Proof. reflexivity. Qed.

Lemma gcd_le : forall n m,
  (Nat.gcd (S n) (S m) <= S n /\ Nat.gcd (S n) (S m) <= S m)%nat.
Proof.
  intros n m.
  pose proof (Nat.gcd_divide (S n) (S m)).
  split; apply Nat.divide_pos_le; try easy; lia.
Qed.

Lemma div_mul_combine : forall a b c d,
  Nat.divide b a -> Nat.divide d c ->
  (a / b * (c / d) = (a * c) / (b * d))%nat.
Proof.
  intros a b c d [a' Ha'] [c' Hc'].
  subst a c.
  destruct b;
  [rewrite ?Nat.mul_0_r, ?Nat.mul_0_l; easy|].
  rewrite Nat.div_mul by easy.
  destruct d;
  [rewrite ?Nat.mul_0_r, ?Nat.mul_0_l; easy|].
  rewrite Nat.div_mul by easy.
  rewrite <- Nat.mul_assoc, (Nat.mul_comm (S b)), <- Nat.mul_assoc, 
    Nat.mul_assoc, (Nat.mul_comm (S d)), Nat.div_mul by lia.
  easy.
Qed.

Lemma prod_eq_gcd_lcm : forall n m,
  (S n * S m = Nat.gcd (S n) (S m) * Nat.lcm (S n) (S m))%nat.
Proof.
  intros n m.
  unfold Nat.lcm.
  rewrite <- 2!Nat.divide_div_mul_exact, (Nat.mul_comm (Nat.gcd _ _)),
    Nat.div_mul; try easy;
  try (try apply Nat.divide_mul_r; apply Nat.gcd_divide; lia);
  rewrite Nat.gcd_eq_0; lia.
Qed.

Lemma gcd_eq_div_lcm : forall n m,
  (Nat.gcd (S n) (S m) = (S n * S m) / (Nat.lcm (S n) (S m)))%nat.
Proof.
  intros n m.
  rewrite prod_eq_gcd_lcm, Nat.div_mul; try easy.
  rewrite Nat.lcm_eq_0; lia.
Qed.



Lemma times_n_C1 : forall n, 
  times_n C1 n = RtoC (INR n).
Proof.
  induction n; [easy|].
  rewrite S_INR, RtoC_plus, <- IHn, Cplus_comm.
  easy.
Qed.


Lemma div_0_r : forall n, 
  (n / 0 = 0)%nat.
Proof.
  intros n.
  easy.
Qed.

Lemma div_divides : forall n m, 
  Nat.divide m n -> (n / m <> 0)%nat ->
  Nat.divide (n / m) n.
Proof.
  intros n m Hdiv Hnz.
  assert (H: m <> O) by (intros Hfalse; subst m; rewrite div_0_r in *; lia).
  exists m.
  rewrite <- Nat.divide_div_mul_exact, Nat.mul_comm, Nat.div_mul; try easy.
Qed.

Lemma div_div : forall n m, 
  Nat.divide m n -> (n / m <> 0)%nat -> 
  (n / (n / m) = m)%nat.
Proof.
  intros n m Hdiv Hnz.
  rewrite <- (Nat.mul_cancel_r _ _ (n/m)) by easy.
  rewrite Nat.mul_comm.
  
  assert (H: m <> O) by (intros Hfalse; subst m; rewrite div_0_r in *; lia).
  rewrite <- Nat.divide_div_mul_exact, Nat.mul_comm, Nat.div_mul; try easy.
  rewrite <- Nat.divide_div_mul_exact, Nat.mul_comm, Nat.div_mul; try easy.
  apply div_divides; easy.
Qed.

Lemma f_to_vec_split : forall (f : nat -> bool) (m n : nat),
  f_to_vec (m + n) f = f_to_vec m f ⊗ f_to_vec n (VectorStates.shift f m).
Proof.
  intros f m n.
  rewrite f_to_vec_merge.
  apply f_to_vec_eq.
  intros i Hi.
  unfold VectorStates.shift.
  bdestructΩ'.
  f_equal; lia.
Qed.

Lemma n_top_to_bottom_semantics_eq_kron_comm : forall n o,
  ⟦ n_top_to_bottom n o ⟧ = kron_comm (2^o) (2^n).
Proof.
  intros n o.
  rewrite zxperm_permutation_semantics by auto with zxperm_db.
  unfold zxperm_to_matrix.
  rewrite perm_of_n_top_to_bottom.
  apply equal_on_basis_states_implies_equal; auto with wf_db.
  1: {
  rewrite Nat.add_comm, Nat.pow_add_r.
  auto with wf_db.
  }
  intros f.
  pose proof (perm_to_matrix_permutes_qubits (n + o) (rotr (n+o) n) f).
  unfold perm_to_matrix in H.
  rewrite H by auto with perm_db.
  rewrite (f_to_vec_split f).
  pose proof (kron_comm_commutes_vectors_l (2^o) (2^n)
  (f_to_vec n f) (f_to_vec o (@VectorStates.shift bool f n))
  ltac:(auto with wf_db) ltac:(auto with wf_db)).
  replace (2^(n+o))%nat with (2^o *2^n)%nat by (rewrite Nat.pow_add_r; lia).
  simpl in H0.
  rewrite H0.
  rewrite Nat.add_comm, f_to_vec_split.
  f_equal.
  - apply f_to_vec_eq.
  intros i Hi.
  unfold VectorStates.shift.
  f_equal; unfold rotr.
  rewrite Nat.mod_small by lia.
  bdestructΩ'.
  - apply f_to_vec_eq.
  intros i Hi.
  unfold VectorStates.shift, rotr.
  rewrite <- Nat.add_assoc, mod_add_n_r, Nat.mod_small by lia.
  bdestructΩ'.
Qed.

Lemma n_top_to_bottom_semantics_eq_kron_comm_mat_equiv : forall n o,
  ⟦ n_top_to_bottom n o ⟧ ≡ kron_comm (2^o) (2^n).
Proof.
  intros n o.
  rewrite n_top_to_bottom_semantics_eq_kron_comm; easy.
Qed.

Lemma compose_semantics' :
forall {n m o : nat} (zx0 : ZX n m) (zx1 : ZX m o),
@eq (Matrix (Nat.pow 2 o) (Nat.pow 2 n))
  (@ZX_semantics n o (@Compose n m o zx0 zx1))
  (@Mmult (Nat.pow 2 o) (Nat.pow 2 m) (Nat.pow 2 n) 
	 (@ZX_semantics m o zx1) (@ZX_semantics n m zx0)).
Proof.
  intros.
  rewrite (@compose_semantics n m o).
  easy.
Qed.
