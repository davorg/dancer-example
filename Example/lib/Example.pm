package Example;
use Dancer2;
use Digest::SHA qw(sha256_hex);
use Example::Schema;
use Net::OAuth2::Profile::WebServer;

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

# Initialize Google OAuth2 client
sub get_google_oauth_client {
    return Net::OAuth2::Profile::WebServer->new(
        client_id     => config->{oauth}->{google}->{client_id},
        client_secret => config->{oauth}->{google}->{client_secret},
        site          => 'https://accounts.google.com',
        authorize_path => '/o/oauth2/auth',
        access_token_path => '/o/oauth2/token',
        redirect_uri  => config->{oauth}->{google}->{redirect_uri},
    );
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
    
    # Add user registration logic (e.g., save user to database)
    my $schema = get_schema();
    eval {
        $schema->resultset('User')->create({
            username => $username,
            password => $password,
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
    
    if ($user && $user->check_password($password)) {
        # Store user information in session
        session user => { username => $user->username, email => $user->email };
        
        # Redirect to home page after successful login
        redirect '/';
    } else {
        return template 'login' => { 'title' => 'Login', 'error' => 'Invalid username or password' };
    }
};

get '/auth/google' => sub {
    my $client = get_google_oauth_client();
    redirect $client->authorize_url(
        scope => config->{oauth}->{google}->{scope},
        response_type => 'code',
    );
};

get '/auth/google/callback' => sub {
    my $client = get_google_oauth_client();
    my $code = query_parameters->get('code');
    my $token = $client->get_access_token($code);
    my $response = $client->get('https://www.googleapis.com/oauth2/v1/userinfo', { Authorization => "Bearer " . $token->access_token });
    my $user_info = from_json($response->content);
    
    my $schema = get_schema();
    my $user = $schema->resultset('User')->find_or_create({
        google_id => $user_info->{id},
        email     => $user_info->{email},
    });
    
    session user => { username => $user->username, email => $user->email };
    redirect '/';
};

get '/logout' => sub {
    # Clear the user session
    app->destroy_session;
    
    # Redirect to home page after logging out
    redirect '/';
};
