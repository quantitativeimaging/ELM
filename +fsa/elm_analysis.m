function elm_analysis(input_dir, output_dir, pixel_size, model_type)

w = warning('query', 'MATLAB:MKDIR:DirectoryExists');
if (strcmp(w.state, 'on'))
	warning('off', 'MATLAB:MKDIR:DirectoryExists')
	mkdir(output_dir)
	warning('on', 'MATLAB:MKDIR:DirectoryExists')
else
	mkdir(output_dir)
end


switch model_type
	case 'spherical'
		fsa.elm_spherical_analysis(input_dir, output_dir, pixel_size);
	case 'ellipsoidal'
		fsa.elm_ellipsoidal_analysis(input_dir, output_dir, pixel_size);
	otherwise
		error('Unsupported model type. Supported types are ''spherical'' and ''ellipsoidal''.');
end

end
