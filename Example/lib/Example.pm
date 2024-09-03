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
    
    # Add user login logic (e.g., authenticate user)
    
    # Redirect to home page after successful login
    redirect '/';
};

true;
