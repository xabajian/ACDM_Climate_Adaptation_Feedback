/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Create NDC gaps from Meinhausen 2022
*/


// cd "/Volumes/ext_drive/Results/"
cd "/Volumes/ext_drive/uncertainty_8_12_22"
global root "/Volumes/ext_drive/uncertainty_8_12_22"
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"
global objects "$root/objects"
global NDCs  "$root/NDCs"





/*
!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$

Step 1: Read in all of the unconditional nationally determined contribution (NDC) time  series from Meinhausen et al 2022.

https://www.nature.com/articles/s41586-022-04553-z#data-availability


!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$
*/


//uncondtional list
// global ndc_list "afg_ndc_14Feb2022b_CR_unconditional_all	ago_ndc_14Feb2022b_CR_unconditional_all	ai_ndc_14Feb2022b_CR_unconditional_all	alb_ndc_14Feb2022b_CR_unconditional_all	and_ndc_14Feb2022b_CR_unconditional_all	are_ndc_14Feb2022b_CR_unconditional_all	arg_ndc_14Feb2022b_CR_unconditional_all	arm_ndc_14Feb2022b_CR_unconditional_all	art4 groups_ndc_14Feb2022b_CR_unconditional_all	atg_ndc_14Feb2022b_CR_unconditional_all	aus_ndc_14Feb2022b_CR_unconditional_all	aut_ndc_14Feb2022b_CR_unconditional_all	aze_ndc_14Feb2022b_CR_unconditional_all	bdi_ndc_14Feb2022b_CR_unconditional_all	bel_ndc_14Feb2022b_CR_unconditional_all	ben_ndc_14Feb2022b_CR_unconditional_all	bfa_ndc_14Feb2022b_CR_unconditional_all	bgd_ndc_14Feb2022b_CR_unconditional_all	bgr_ndc_14Feb2022b_CR_unconditional_all	bhr_ndc_14Feb2022b_CR_unconditional_all	bhs_ndc_14Feb2022b_CR_unconditional_all	bih_ndc_14Feb2022b_CR_unconditional_all	blr_ndc_14Feb2022b_CR_unconditional_all	blz_ndc_14Feb2022b_CR_unconditional_all	bol_ndc_14Feb2022b_CR_unconditional_all	bra_ndc_14Feb2022b_CR_unconditional_all	brb_ndc_14Feb2022b_CR_unconditional_all	brn_ndc_14Feb2022b_CR_unconditional_all	btn_ndc_14Feb2022b_CR_unconditional_all	bwa_ndc_14Feb2022b_CR_unconditional_all	caf_ndc_14Feb2022b_CR_unconditional_all	can_ndc_14Feb2022b_CR_unconditional_all	che_ndc_14Feb2022b_CR_unconditional_all	chl_ndc_14Feb2022b_CR_unconditional_all	chn_ndc_14Feb2022b_CR_unconditional_all	civ_ndc_14Feb2022b_CR_unconditional_all	cmr_ndc_14Feb2022b_CR_unconditional_all	cod_ndc_14Feb2022b_CR_unconditional_all	cog_ndc_14Feb2022b_CR_unconditional_all	cok_ndc_14Feb2022b_CR_unconditional_all	col_ndc_14Feb2022b_CR_unconditional_all	com_ndc_14Feb2022b_CR_unconditional_all	cpv_ndc_14Feb2022b_CR_unconditional_all	cri_ndc_14Feb2022b_CR_unconditional_all	cub_ndc_14Feb2022b_CR_unconditional_all	cyp_ndc_14Feb2022b_CR_unconditional_all	cze_ndc_14Feb2022b_CR_unconditional_all	deu_ndc_14Feb2022b_CR_unconditional_all	dji_ndc_14Feb2022b_CR_unconditional_all	dma_ndc_14Feb2022b_CR_unconditional_all	dnk_ndc_14Feb2022b_CR_unconditional_all	dom_ndc_14Feb2022b_CR_unconditional_all	dza_ndc_14Feb2022b_CR_unconditional_all	ecu_ndc_14Feb2022b_CR_unconditional_all	egy_ndc_14Feb2022b_CR_unconditional_all	eri_ndc_14Feb2022b_CR_unconditional_all	esp_ndc_14Feb2022b_CR_unconditional_all	est_ndc_14Feb2022b_CR_unconditional_all	eth_ndc_14Feb2022b_CR_unconditional_all	eu27_ndc_14Feb2022b_CR_unconditional_all	eua_ndc_14Feb2022b_CR_unconditional_all	fin_ndc_14Feb2022b_CR_unconditional_all	fji_ndc_14Feb2022b_CR_unconditional_all	fra_ndc_14Feb2022b_CR_unconditional_all	fsm_ndc_14Feb2022b_CR_unconditional_all	g7_ndc_14Feb2022b_CR_unconditional_all	g20_ndc_14Feb2022b_CR_unconditional_all	gab_ndc_14Feb2022b_CR_unconditional_all	gbr_ndc_14Feb2022b_CR_unconditional_all	geo_ndc_14Feb2022b_CR_unconditional_all	gha_ndc_14Feb2022b_CR_unconditional_all	gin_ndc_14Feb2022b_CR_unconditional_all	gmb_ndc_14Feb2022b_CR_unconditional_all	gnb_ndc_14Feb2022b_CR_unconditional_all	gnq_ndc_14Feb2022b_CR_unconditional_all	grc_ndc_14Feb2022b_CR_unconditional_all	grd_ndc_14Feb2022b_CR_unconditional_all	groupabc2_ndc_14Feb2022b_CR_unconditional_all	groupabc3_ndc_14Feb2022b_CR_unconditional_all	groupafrica_ndc_14Feb2022b_CR_unconditional_all	groupaii_ndc_14Feb2022b_CR_unconditional_all	groupasia_ndc_14Feb2022b_CR_unconditional_all	groupasiapac_ndc_14Feb2022b_CR_unconditional_all	groupeasterneur_ndc_14Feb2022b_CR_unconditional_all	groupeu27_ndc_14Feb2022b_CR_unconditional_all	groupeu28_ndc_14Feb2022b_CR_unconditional_all	groupindc_ndc_14Feb2022b_CR_unconditional_all	grouplam_ndc_14Feb2022b_CR_unconditional_all	grouplatincarr_ndc_14Feb2022b_CR_unconditional_all	groupmaf_ndc_14Feb2022b_CR_unconditional_all	groupoecd90_ndc_14Feb2022b_CR_unconditional_all	groupref_ndc_14Feb2022b_CR_unconditional_all	grouprestasia_ndc_14Feb2022b_CR_unconditional_all	grouprestoecd90_ndc_14Feb2022b_CR_unconditional_all	grouprestref_ndc_14Feb2022b_CR_unconditional_all	groups_ndc_14Feb2022b_CR_unconditional_all	groupwesteuronam_ndc_14Feb2022b_CR_unconditional_all	groupworld_ndc_14Feb2022b_CR_unconditional_all	gtm_ndc_14Feb2022b_CR_unconditional_all	guy_ndc_14Feb2022b_CR_unconditional_all	hnd_ndc_14Feb2022b_CR_unconditional_all	hrv_ndc_14Feb2022b_CR_unconditional_all	hti_ndc_14Feb2022b_CR_unconditional_all	hun_ndc_14Feb2022b_CR_unconditional_all	idn_ndc_14Feb2022b_CR_unconditional_all	ind_ndc_14Feb2022b_CR_unconditional_all	irl_ndc_14Feb2022b_CR_unconditional_all	irn_ndc_14Feb2022b_CR_unconditional_all	irq_ndc_14Feb2022b_CR_unconditional_all	isl_ndc_14Feb2022b_CR_unconditional_all	isr_ndc_14Feb2022b_CR_unconditional_all	ita_ndc_14Feb2022b_CR_unconditional_all	jam_ndc_14Feb2022b_CR_unconditional_all	jor_ndc_14Feb2022b_CR_unconditional_all	jpn_ndc_14Feb2022b_CR_unconditional_all	kaz_ndc_14Feb2022b_CR_unconditional_all	ken_ndc_14Feb2022b_CR_unconditional_all	kgz_ndc_14Feb2022b_CR_unconditional_all	khm_ndc_14Feb2022b_CR_unconditional_all	kir_ndc_14Feb2022b_CR_unconditional_all	kna_ndc_14Feb2022b_CR_unconditional_all	kor_ndc_14Feb2022b_CR_unconditional_all	kwt_ndc_14Feb2022b_CR_unconditional_all	lao_ndc_14Feb2022b_CR_unconditional_all	lbn_ndc_14Feb2022b_CR_unconditional_all	lbr_ndc_14Feb2022b_CR_unconditional_all	lby_ndc_14Feb2022b_CR_unconditional_all	lca_ndc_14Feb2022b_CR_unconditional_all	lie_ndc_14Feb2022b_CR_unconditional_all	lka_ndc_14Feb2022b_CR_unconditional_all	lso_ndc_14Feb2022b_CR_unconditional_all	ltu_ndc_14Feb2022b_CR_unconditional_all	lux_ndc_14Feb2022b_CR_unconditional_all	lva_ndc_14Feb2022b_CR_unconditional_all	mar_ndc_14Feb2022b_CR_unconditional_all	mco_ndc_14Feb2022b_CR_unconditional_all	mda_ndc_14Feb2022b_CR_unconditional_all	mdg_ndc_14Feb2022b_CR_unconditional_all	mdv_ndc_14Feb2022b_CR_unconditional_all	mex_ndc_14Feb2022b_CR_unconditional_all	mhl_ndc_14Feb2022b_CR_unconditional_all	mkd_ndc_14Feb2022b_CR_unconditional_all	mli_ndc_14Feb2022b_CR_unconditional_all	mlt_ndc_14Feb2022b_CR_unconditional_all	mmr_ndc_14Feb2022b_CR_unconditional_all	mne_ndc_14Feb2022b_CR_unconditional_all	mng_ndc_14Feb2022b_CR_unconditional_all	moz_ndc_14Feb2022b_CR_unconditional_all	mrt_ndc_14Feb2022b_CR_unconditional_all	mus_ndc_14Feb2022b_CR_unconditional_all	mwi_ndc_14Feb2022b_CR_unconditional_all	mys_ndc_14Feb2022b_CR_unconditional_all	nai_ndc_14Feb2022b_CR_unconditional_all	nam_ndc_14Feb2022b_CR_unconditional_all	ndcs2050_ndc_14Feb2022b_CR_unconditional_all	ner_ndc_14Feb2022b_CR_unconditional_all	nga_ndc_14Feb2022b_CR_unconditional_all	nic_ndc_14Feb2022b_CR_unconditional_all	niu_ndc_14Feb2022b_CR_unconditional_all	nld_ndc_14Feb2022b_CR_unconditional_all	nor_ndc_14Feb2022b_CR_unconditional_all	npl_ndc_14Feb2022b_CR_unconditional_all	nru_ndc_14Feb2022b_CR_unconditional_all	nundcs_ndc_14Feb2022b_CR_unconditional_all	nzl_ndc_14Feb2022b_CR_unconditional_all	omn_ndc_14Feb2022b_CR_unconditional_all	pak_ndc_14Feb2022b_CR_unconditional_all	pan_ndc_14Feb2022b_CR_unconditional_all	paparty_ndc_14Feb2022b_CR_unconditional_all	papartywithndc_ndc_14Feb2022b_CR_unconditional_all	per_ndc_14Feb2022b_CR_unconditional_all	phl_ndc_14Feb2022b_CR_unconditional_all	plw_ndc_14Feb2022b_CR_unconditional_all	png_ndc_14Feb2022b_CR_unconditional_all	pol_ndc_14Feb2022b_CR_unconditional_all	prk_ndc_14Feb2022b_CR_unconditional_all	prt_ndc_14Feb2022b_CR_unconditional_all	pry_ndc_14Feb2022b_CR_unconditional_all	pse_ndc_14Feb2022b_CR_unconditional_all	qat_ndc_14Feb2022b_CR_unconditional_all	rou_ndc_14Feb2022b_CR_unconditional_all	rus_ndc_14Feb2022b_CR_unconditional_all	rwa_ndc_14Feb2022b_CR_unconditional_all	sau_ndc_14Feb2022b_CR_unconditional_all	sdn_ndc_14Feb2022b_CR_unconditional_all	sen_ndc_14Feb2022b_CR_unconditional_all	sgp_ndc_14Feb2022b_CR_unconditional_all	slb_ndc_14Feb2022b_CR_unconditional_all	sle_ndc_14Feb2022b_CR_unconditional_all	slv_ndc_14Feb2022b_CR_unconditional_all	smr_ndc_14Feb2022b_CR_unconditional_all	som_ndc_14Feb2022b_CR_unconditional_all	srb_ndc_14Feb2022b_CR_unconditional_all	ssd_ndc_14Feb2022b_CR_unconditional_all	stp_ndc_14Feb2022b_CR_unconditional_all	sur_ndc_14Feb2022b_CR_unconditional_all	svk_ndc_14Feb2022b_CR_unconditional_all	svn_ndc_14Feb2022b_CR_unconditional_all	swe_ndc_14Feb2022b_CR_unconditional_all	swz_ndc_14Feb2022b_CR_unconditional_all	syc_ndc_14Feb2022b_CR_unconditional_all	syr_ndc_14Feb2022b_CR_unconditional_all	tcd_ndc_14Feb2022b_CR_unconditional_all	tgo_ndc_14Feb2022b_CR_unconditional_all	tha_ndc_14Feb2022b_CR_unconditional_all	tjk_ndc_14Feb2022b_CR_unconditional_all	tkm_ndc_14Feb2022b_CR_unconditional_all	tls_ndc_14Feb2022b_CR_unconditional_all	ton_ndc_14Feb2022b_CR_unconditional_all	tto_ndc_14Feb2022b_CR_unconditional_all	tun_ndc_14Feb2022b_CR_unconditional_all	tur_ndc_14Feb2022b_CR_unconditional_all	tuv_ndc_14Feb2022b_CR_unconditional_all	tza_ndc_14Feb2022b_CR_unconditional_all	uga_ndc_14Feb2022b_CR_unconditional_all	ukr_ndc_14Feb2022b_CR_unconditional_all	ury_ndc_14Feb2022b_CR_unconditional_all	usa_ndc_14Feb2022b_CR_unconditional_all	uzb_ndc_14Feb2022b_CR_unconditional_all	vct_ndc_14Feb2022b_CR_unconditional_all	ven_ndc_14Feb2022b_CR_unconditional_all	vnm_ndc_14Feb2022b_CR_unconditional_all	vut_ndc_14Feb2022b_CR_unconditional_all	wsm_ndc_14Feb2022b_CR_unconditional_all	yem_ndc_14Feb2022b_CR_unconditional_all	zaf_ndc_14Feb2022b_CR_unconditional_all	zmb_ndc_14Feb2022b_CR_unconditional_all	zwe_ndc_14Feb2022b_CR_unconditional_all	zza_ndc_14Feb2022b_CR_unconditional_all	zzb_ndc_14Feb2022b_CR_unconditional_all"

//conditional list
global ndc_list "afg_ndc_14Feb2022b_CR_conditional_all	ago_ndc_14Feb2022b_CR_conditional_all	ai_ndc_14Feb2022b_CR_conditional_all	alb_ndc_14Feb2022b_CR_conditional_all	and_ndc_14Feb2022b_CR_conditional_all	are_ndc_14Feb2022b_CR_conditional_all	arg_ndc_14Feb2022b_CR_conditional_all	arm_ndc_14Feb2022b_CR_conditional_all	art4 groups_ndc_14Feb2022b_CR_conditional_all	atg_ndc_14Feb2022b_CR_conditional_all	aus_ndc_14Feb2022b_CR_conditional_all	aut_ndc_14Feb2022b_CR_conditional_all	aze_ndc_14Feb2022b_CR_conditional_all	bdi_ndc_14Feb2022b_CR_conditional_all	bel_ndc_14Feb2022b_CR_conditional_all	ben_ndc_14Feb2022b_CR_conditional_all	bfa_ndc_14Feb2022b_CR_conditional_all	bgd_ndc_14Feb2022b_CR_conditional_all	bgr_ndc_14Feb2022b_CR_conditional_all	bhr_ndc_14Feb2022b_CR_conditional_all	bhs_ndc_14Feb2022b_CR_conditional_all	bih_ndc_14Feb2022b_CR_conditional_all	blr_ndc_14Feb2022b_CR_conditional_all	blz_ndc_14Feb2022b_CR_conditional_all	bol_ndc_14Feb2022b_CR_conditional_all	bra_ndc_14Feb2022b_CR_conditional_all	brb_ndc_14Feb2022b_CR_conditional_all	brn_ndc_14Feb2022b_CR_conditional_all	btn_ndc_14Feb2022b_CR_conditional_all	bwa_ndc_14Feb2022b_CR_conditional_all	caf_ndc_14Feb2022b_CR_conditional_all	can_ndc_14Feb2022b_CR_conditional_all	che_ndc_14Feb2022b_CR_conditional_all	chl_ndc_14Feb2022b_CR_conditional_all	chn_ndc_14Feb2022b_CR_conditional_all	civ_ndc_14Feb2022b_CR_conditional_all	cmr_ndc_14Feb2022b_CR_conditional_all	cod_ndc_14Feb2022b_CR_conditional_all	cog_ndc_14Feb2022b_CR_conditional_all	cok_ndc_14Feb2022b_CR_conditional_all	col_ndc_14Feb2022b_CR_conditional_all	com_ndc_14Feb2022b_CR_conditional_all	cpv_ndc_14Feb2022b_CR_conditional_all	cri_ndc_14Feb2022b_CR_conditional_all	cub_ndc_14Feb2022b_CR_conditional_all	cyp_ndc_14Feb2022b_CR_conditional_all	cze_ndc_14Feb2022b_CR_conditional_all	deu_ndc_14Feb2022b_CR_conditional_all	dji_ndc_14Feb2022b_CR_conditional_all	dma_ndc_14Feb2022b_CR_conditional_all	dnk_ndc_14Feb2022b_CR_conditional_all	dom_ndc_14Feb2022b_CR_conditional_all	dza_ndc_14Feb2022b_CR_conditional_all	ecu_ndc_14Feb2022b_CR_conditional_all	egy_ndc_14Feb2022b_CR_conditional_all	eri_ndc_14Feb2022b_CR_conditional_all	esp_ndc_14Feb2022b_CR_conditional_all	est_ndc_14Feb2022b_CR_conditional_all	eth_ndc_14Feb2022b_CR_conditional_all	eu27_ndc_14Feb2022b_CR_conditional_all	eua_ndc_14Feb2022b_CR_conditional_all	fin_ndc_14Feb2022b_CR_conditional_all	fji_ndc_14Feb2022b_CR_conditional_all	fra_ndc_14Feb2022b_CR_conditional_all	fsm_ndc_14Feb2022b_CR_conditional_all	g7_ndc_14Feb2022b_CR_conditional_all	g20_ndc_14Feb2022b_CR_conditional_all	gab_ndc_14Feb2022b_CR_conditional_all	gbr_ndc_14Feb2022b_CR_conditional_all	geo_ndc_14Feb2022b_CR_conditional_all	gha_ndc_14Feb2022b_CR_conditional_all	gin_ndc_14Feb2022b_CR_conditional_all	gmb_ndc_14Feb2022b_CR_conditional_all	gnb_ndc_14Feb2022b_CR_conditional_all	gnq_ndc_14Feb2022b_CR_conditional_all	grc_ndc_14Feb2022b_CR_conditional_all	grd_ndc_14Feb2022b_CR_conditional_all	groupabc2_ndc_14Feb2022b_CR_conditional_all	groupabc3_ndc_14Feb2022b_CR_conditional_all	groupafrica_ndc_14Feb2022b_CR_conditional_all	groupaii_ndc_14Feb2022b_CR_conditional_all	groupasia_ndc_14Feb2022b_CR_conditional_all	groupasiapac_ndc_14Feb2022b_CR_conditional_all	groupeasterneur_ndc_14Feb2022b_CR_conditional_all	groupeu27_ndc_14Feb2022b_CR_conditional_all	groupeu28_ndc_14Feb2022b_CR_conditional_all	groupindc_ndc_14Feb2022b_CR_conditional_all	grouplam_ndc_14Feb2022b_CR_conditional_all	grouplatincarr_ndc_14Feb2022b_CR_conditional_all	groupmaf_ndc_14Feb2022b_CR_conditional_all	groupoecd90_ndc_14Feb2022b_CR_conditional_all	groupref_ndc_14Feb2022b_CR_conditional_all	grouprestasia_ndc_14Feb2022b_CR_conditional_all	grouprestoecd90_ndc_14Feb2022b_CR_conditional_all	grouprestref_ndc_14Feb2022b_CR_conditional_all	groups_ndc_14Feb2022b_CR_conditional_all	groupwesteuronam_ndc_14Feb2022b_CR_conditional_all	groupworld_ndc_14Feb2022b_CR_conditional_all	gtm_ndc_14Feb2022b_CR_conditional_all	guy_ndc_14Feb2022b_CR_conditional_all	hnd_ndc_14Feb2022b_CR_conditional_all	hrv_ndc_14Feb2022b_CR_conditional_all	hti_ndc_14Feb2022b_CR_conditional_all	hun_ndc_14Feb2022b_CR_conditional_all	idn_ndc_14Feb2022b_CR_conditional_all	ind_ndc_14Feb2022b_CR_conditional_all	irl_ndc_14Feb2022b_CR_conditional_all	irn_ndc_14Feb2022b_CR_conditional_all	irq_ndc_14Feb2022b_CR_conditional_all	isl_ndc_14Feb2022b_CR_conditional_all	isr_ndc_14Feb2022b_CR_conditional_all	ita_ndc_14Feb2022b_CR_conditional_all	jam_ndc_14Feb2022b_CR_conditional_all	jor_ndc_14Feb2022b_CR_conditional_all	jpn_ndc_14Feb2022b_CR_conditional_all	kaz_ndc_14Feb2022b_CR_conditional_all	ken_ndc_14Feb2022b_CR_conditional_all	kgz_ndc_14Feb2022b_CR_conditional_all	khm_ndc_14Feb2022b_CR_conditional_all	kir_ndc_14Feb2022b_CR_conditional_all	kna_ndc_14Feb2022b_CR_conditional_all	kor_ndc_14Feb2022b_CR_conditional_all	kwt_ndc_14Feb2022b_CR_conditional_all	lao_ndc_14Feb2022b_CR_conditional_all	lbn_ndc_14Feb2022b_CR_conditional_all	lbr_ndc_14Feb2022b_CR_conditional_all	lby_ndc_14Feb2022b_CR_conditional_all	lca_ndc_14Feb2022b_CR_conditional_all	lie_ndc_14Feb2022b_CR_conditional_all	lka_ndc_14Feb2022b_CR_conditional_all	lso_ndc_14Feb2022b_CR_conditional_all	ltu_ndc_14Feb2022b_CR_conditional_all	lux_ndc_14Feb2022b_CR_conditional_all	lva_ndc_14Feb2022b_CR_conditional_all	mar_ndc_14Feb2022b_CR_conditional_all	mco_ndc_14Feb2022b_CR_conditional_all	mda_ndc_14Feb2022b_CR_conditional_all	mdg_ndc_14Feb2022b_CR_conditional_all	mdv_ndc_14Feb2022b_CR_conditional_all	mex_ndc_14Feb2022b_CR_conditional_all	mhl_ndc_14Feb2022b_CR_conditional_all	mkd_ndc_14Feb2022b_CR_conditional_all	mli_ndc_14Feb2022b_CR_conditional_all	mlt_ndc_14Feb2022b_CR_conditional_all	mmr_ndc_14Feb2022b_CR_conditional_all	mne_ndc_14Feb2022b_CR_conditional_all	mng_ndc_14Feb2022b_CR_conditional_all	moz_ndc_14Feb2022b_CR_conditional_all	mrt_ndc_14Feb2022b_CR_conditional_all	mus_ndc_14Feb2022b_CR_conditional_all	mwi_ndc_14Feb2022b_CR_conditional_all	mys_ndc_14Feb2022b_CR_conditional_all	nai_ndc_14Feb2022b_CR_conditional_all	nam_ndc_14Feb2022b_CR_conditional_all	ndcs2050_ndc_14Feb2022b_CR_conditional_all	ner_ndc_14Feb2022b_CR_conditional_all	nga_ndc_14Feb2022b_CR_conditional_all	nic_ndc_14Feb2022b_CR_conditional_all	niu_ndc_14Feb2022b_CR_conditional_all	nld_ndc_14Feb2022b_CR_conditional_all	nor_ndc_14Feb2022b_CR_conditional_all	npl_ndc_14Feb2022b_CR_conditional_all	nru_ndc_14Feb2022b_CR_conditional_all	nundcs_ndc_14Feb2022b_CR_conditional_all	nzl_ndc_14Feb2022b_CR_conditional_all	omn_ndc_14Feb2022b_CR_conditional_all	pak_ndc_14Feb2022b_CR_conditional_all	pan_ndc_14Feb2022b_CR_conditional_all	paparty_ndc_14Feb2022b_CR_conditional_all	papartywithndc_ndc_14Feb2022b_CR_conditional_all	per_ndc_14Feb2022b_CR_conditional_all	phl_ndc_14Feb2022b_CR_conditional_all	plw_ndc_14Feb2022b_CR_conditional_all	png_ndc_14Feb2022b_CR_conditional_all	pol_ndc_14Feb2022b_CR_conditional_all	prk_ndc_14Feb2022b_CR_conditional_all	prt_ndc_14Feb2022b_CR_conditional_all	pry_ndc_14Feb2022b_CR_conditional_all	pse_ndc_14Feb2022b_CR_conditional_all	qat_ndc_14Feb2022b_CR_conditional_all	rou_ndc_14Feb2022b_CR_conditional_all	rus_ndc_14Feb2022b_CR_conditional_all	rwa_ndc_14Feb2022b_CR_conditional_all	sau_ndc_14Feb2022b_CR_conditional_all	sdn_ndc_14Feb2022b_CR_conditional_all	sen_ndc_14Feb2022b_CR_conditional_all	sgp_ndc_14Feb2022b_CR_conditional_all	slb_ndc_14Feb2022b_CR_conditional_all	sle_ndc_14Feb2022b_CR_conditional_all	slv_ndc_14Feb2022b_CR_conditional_all	smr_ndc_14Feb2022b_CR_conditional_all	som_ndc_14Feb2022b_CR_conditional_all	srb_ndc_14Feb2022b_CR_conditional_all	ssd_ndc_14Feb2022b_CR_conditional_all	stp_ndc_14Feb2022b_CR_conditional_all	sur_ndc_14Feb2022b_CR_conditional_all	svk_ndc_14Feb2022b_CR_conditional_all	svn_ndc_14Feb2022b_CR_conditional_all	swe_ndc_14Feb2022b_CR_conditional_all	swz_ndc_14Feb2022b_CR_conditional_all	syc_ndc_14Feb2022b_CR_conditional_all	syr_ndc_14Feb2022b_CR_conditional_all	tcd_ndc_14Feb2022b_CR_conditional_all	tgo_ndc_14Feb2022b_CR_conditional_all	tha_ndc_14Feb2022b_CR_conditional_all	tjk_ndc_14Feb2022b_CR_conditional_all	tkm_ndc_14Feb2022b_CR_conditional_all	tls_ndc_14Feb2022b_CR_conditional_all	ton_ndc_14Feb2022b_CR_conditional_all	tto_ndc_14Feb2022b_CR_conditional_all	tun_ndc_14Feb2022b_CR_conditional_all	tur_ndc_14Feb2022b_CR_conditional_all	tuv_ndc_14Feb2022b_CR_conditional_all	tza_ndc_14Feb2022b_CR_conditional_all	uga_ndc_14Feb2022b_CR_conditional_all	ukr_ndc_14Feb2022b_CR_conditional_all	ury_ndc_14Feb2022b_CR_conditional_all	usa_ndc_14Feb2022b_CR_conditional_all	uzb_ndc_14Feb2022b_CR_conditional_all	vct_ndc_14Feb2022b_CR_conditional_all	ven_ndc_14Feb2022b_CR_conditional_all	vnm_ndc_14Feb2022b_CR_conditional_all	vut_ndc_14Feb2022b_CR_conditional_all	wsm_ndc_14Feb2022b_CR_conditional_all	yem_ndc_14Feb2022b_CR_conditional_all	zaf_ndc_14Feb2022b_CR_conditional_all	zmb_ndc_14Feb2022b_CR_conditional_all	zwe_ndc_14Feb2022b_CR_conditional_all	zza_ndc_14Feb2022b_CR_conditional_all	zzb_ndc_14Feb2022b_CR_conditional_all"

/*
!#@$!@#$!$#$
Loop over the NDCs
!#@$!@#$!$#$
*/
scalar error_count=0

foreach ndc of global ndc_list{
	
	capture{	
		
		//import csv
		import delimited "$NDCs/csvs/`ndc'", clear
		
		//tag NDC name and country
		rename v1 year
		gen full_string = "`ndc'"
		gen ISO3= substr(full_string,1,3)
		
		drop full_string
		

		//save out
		save "$NDCs/dtas/`ndc'.dta", replace
		
	}
	
	
		if _rc!=0 {
			//Add to error counter if errors in loop
			scalar error_count = error_count+1
			display error_count
						}
	
}

display error_count
//8


/*
!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$

Step 2: Create panel (country x year) of NDCs 

!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$
*/
scalar error_count=0
clear

foreach ndc of global ndc_list{
	
	capture{	
		
		append using "$root/NDCs/dtas/`ndc'.dta"
		
	}
	
	
		if _rc!=0 {
			//Add to error counter if errors in loop
			scalar error_count = error_count+1
			display error_count
						}
	
}

display error_count
save "$NDCs/dtas/aggregate_series_conditional.dta", replace
//save "$NDCs/aggregate_series_unconditional.dta", replace


/*
!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$

Step 3: Merge NDC series and with the different series of emissions changes due to adapation 


!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$
*/

use "$NDCs/dtas/aggregate_series_conditional.dta", clear

****RCPs
global rcp_list = "rcp45 rcp85"

****SSP
global ssp_list = "SSP1 SSP2 SSP3 SSP4 SSP5"


//set error count
scalar error_count = 0

foreach rcp_type of global rcp_list{
	foreach ssp_type of global ssp_list{
				
		capture{
		//preserve restore
		preserve 


		 duplicates r ISO3 year
		 duplicates drop ISO3 year, force
		 
		 replace ISO3 = upper(ISO3)
		 /*merge*/
		 
		local name_dummy1 = "adpatation_emissions_ts_"+"`rcp_type'"+"_" +"`ssp_type'"+".dta"
		//merge 1:m year ISO3 using  "$objects/Country_Adaptive_Emissions_TS/`name_dummy1'", gen(merge)
		merge 1:m year ISO3 using  "$objects/Country_Adaptive_Emissions_TS_2/`name_dummy1'", gen(merge)

		keep if merge==3

		sort ISO3 year

		//drop merge GID_0 NAME_0 id
		
		local name_dummy2 = "NDC_adapt_TS_"+"`rcp_type'"+"_" +"`ssp_type'"+".dta"
		save "$objects/NDC_Panels/`name_dummy2'", replace

					
				//end capture					
		}
			
		if _rc!=0 {
			//Add to error counter if errors in loop
			scalar error_count = error_count+1
			display error_count
						}
restore 
		
	}
	
}

display error_count
//0





/*
!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$

Step 4: Test for USA


!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$
*/

use "$objects/NDC_Panels/NDC_adapt_TS_rcp85_SSP5", clear

//first, make sure panel is ship shape
duplicates r ISO3 year
//great


//generate a "ceiling" NDC series from the two i have access ton_ndc_14Feb2022b_CR_conditional_all
gen ndc_ceil = max(ndchighvaluemt,ndclowvaluemt)

//convert all three items of interest into same units (GTCO2-eq)
gen ndc = ndc_ceil/1000
gen ssp5 = ssp5valuemt/1000
gen ssp5_w_adapt = ssp5valuemt/1000 + mean_emissions


//drop years less than 2020
keep if year>2019 
//2030 horizon option
// keep if year<2031

//how many entries of each are missing in the panel?

count
//  4,247

count if mean_emissions==.
drop if mean_emissions==.
count if ndc==.
//1,520
count if ssp5==.
//1,691

count if ssp5_w_adapt==.
//1,601


//OK, generate missing ssp ndc counts for each country time series
gen missing_ndc=(ndc==.)
gen missing_ssp=(ssp5==.)

by ISO3: egen total_missing_ndc = sum(missing_ndc)
by ISO3: egen total_missing_ssp = sum(missing_ssp)

tab ISO3, sum(total_missing_ndc)
tab ISO3, sum(total_missing_ssp)




/*
Next, isolate countries whos NDCs are actually lower than projected SSP5 emissions

Countries with this inequality holding the other way essentially haven't committed to any change

		eg, Albanian NDCs are always larger than their projected SSP5 emissions
*/

gen ndc_lessthan_ssp5 = (ndc<ssp5 & missing_ndc!=1 & missing_ssp!=1)
by ISO3: egen total_nonbind = sum(ndc_lessthan_ssp5)
tab ISO3, sum(total_nonbind)
tab ndc_lessthan_ssp5

/*

OK, create covered year series for countries that have any commitment at all

*/

keep if total_nonbind!=0

replace ndc = ndc_lessthan_ssp5*ndc
replace ssp5 = ndc_lessthan_ssp5*ssp5
replace ssp5_w_adapt = ndc_lessthan_ssp5*ssp5_w_adapt



//generate total emissions in covered yeras under the three scenarios
sort ISO3 year

by ISO3: egen ndc_cumulative = sum(ndc)
by ISO3: egen ssp5_cumulative = sum(ssp5)
by ISO3: egen ssp5_adapt_cumulative = sum(ssp5_w_adapt)


//collapse these cumulative values
collapse  ssp5_adapt_cumulative  ssp5_cumulative  ndc_cumulative, by(ISO3 Country)

//generate the gaps under the two scenarios
gen baseline_gap = (ssp5_cumulative - ndc_cumulative)/ndc_cumulative
gen adapt_gap = (ssp5_adapt_cumulative-ndc_cumulative)/ndc_cumulative

gen gap_ratio = (adapt_gap - baseline_gap)/baseline_gap
sum gap_ratio, d



replace gap_ratio=1 if gap_ratio>=1
replace gap_ratio=-1 if gap_ratio<=-1
//-5 countries


count

/*
We retain 63/76 countries with long-term NDCs 
*/

merge m:1  ISO3 using "$objects/covariates_for_xsection.dta", gen(merge_covariates)
keep if merge_covariates==3


sum gap_ratio, d
//we retain 63 after merging covariates back in
 




 
/*
%%%%%%%%%%%%%%%%%%%%%%
kick out data
%%%%%%%%%%%%%%%%%%%%%%
*/

save "$processed/NDC_gaps.dta", replace 


