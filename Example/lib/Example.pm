package Example;
use Dancer2;

our $VERSION = '0.1';

get '/' => sub {
    template 'index' => { 'title' => 'Example' };
};

get '/register' => sub {
    # Render the registration form template
    template 'register' => { 'title' => 'Register' };
};

post '/register' => sub {
    # Implement user registration logic here
    my $username = body_parameters->get('username');
    my $password = body_parameters->get('password');
    my $confirm_password = body_parameters->get('confirm_password'); # P54ca
    
    # Check if passwords match
    if ($password ne $confirm_password) {
        return template 'register' => { 'title' => 'Register', 'error' => 'Passwords do not match' };
    }
    
    # Add user registration logic (e.g., save user to database)
    
    # Redirect to login page after successful registration
    redirect '/login';
};

get '/login' => sub {
    # Render the login form template
    template 'login' => { 'title' => 'Login' };
};

post '/login' => sub {
    # Implement user login logic here
    my $username = body_parameters->get('username');
    my $password = body_parameters->get('password');
    my $confirm_password = body_parameters->get('confirm_password'); # Pced1
    
    # Check if passwords match
    if ($password ne $confirm_password) {
        return template 'login' => { 'title' => 'Login', 'error' => 'Passwords do not match' };
    }
    
    # Add user login logic (e.g., authenticate user)
    
    # Redirect to home page after successful login
    redirect '/';
};

true;
