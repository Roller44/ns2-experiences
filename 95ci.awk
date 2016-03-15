BEGIN{
	FS = "\t"
}
{
	ln ++
}
{
	d = $0 - t
}
{
	s2 = s2 + d * d
}
END{
	s = sqrt( s2 / (ln -1) );
	f = 1.96 * s / sqrt ( ln );
	printf("sample variance: %f  Conf. Int. 95: %f +/- %f\n", s, t, f);
}
