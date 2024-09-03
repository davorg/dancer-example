package Example;
use Dancer2;
use Digest::SHA qw(sha256_hex);
use Example::Schema;

our $VERSION = '0.1';

# Initialize DBIx::Class schema
sub get_schema {
    my $schema = Example::Schema->connect(
        config->{database}->{dsn},
        config->{database}->{username},
        config->{database}->{password},
    );
    return $schema;
}

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
    my $confirm_password = body_parameters->get('confirm_password');
    my $email = body_parameters->get('email');
    
    # Check if passwords match
    if ($password ne $confirm_password) {
        return template 'register' => { 'title' => 'Register', 'error' => 'Passwords do not match' };
    }
    
    # Encrypt the password
    my $encrypted_password = sha256_hex($password);
    
    # Add user registration logic (e.g., save user to database)
    my $schema = get_schema();
    eval {
        $schema->resultset('User')->create({
            username => $username,
            password => $encrypted_password,
            email    => $email,
        });
    };
    if ($@) {
        error "Database error: $@"; # Log the database error
        return template 'register' => { 'title' => 'Register', 'error' => 'Failed to register user' };
    }
    
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
    my $schema = get_schema();
    my $user = $schema->resultset('User')->find({ username => $username });
    
    if ($user && $user->password eq sha256_hex($password)) {
        # Redirect to home page after successful login
        redirect '/';
    } else {
        return template 'login' => { 'title' => 'Login', 'error' => 'Invalid username or password' };
    }
};

true;
