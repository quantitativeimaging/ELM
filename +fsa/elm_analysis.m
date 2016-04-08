function elm_analysis(input_dir, output_dir, pixel_size, model_type)

switch model_type
	case 'spherical'
		fsa.elm_spherical_analysis(input_dir, output_dir, pixel_size);
	case 'ellipsoidal'
		fsa.elm_ellipsoidal_analysis(input_dir, output_dir, pixel_size);
	otherwise
		error('Unsupported model type. Supported types are ''spherical'' and ''ellipsoidal''.');
end

end
