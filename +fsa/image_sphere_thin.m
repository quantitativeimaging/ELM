function I = image_sphere_thin(x_centre, y_centre, radius, psf_sigma, height, imagemat)

image_width = size(imagemat, 2);
image_height = size(imagemat, 1);

image_centre_x = image_width / 2;
image_centre_y = image_height / 2;

x = (1:image_width) - image_centre_x;
y = -(1:image_height) + image_centre_y;

[x y] = meshgrid(x, y);
X = [x(:) y(:)];

image_vector = fsa.cross_section_sphere_thin(x_centre, y_centre, radius, psf_sigma, height, X);

imagemat = reshape(image_vector, size(imagemat));
I = imagemat;

end
