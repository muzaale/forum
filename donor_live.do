qui {
	cls 
    use ${repo}donor_live, clear
    format pers_esrd_first_service_dt %td
    sum pers_esrd_first_service_dt
    hist pers_esrd_first_service_dt, freq
}
