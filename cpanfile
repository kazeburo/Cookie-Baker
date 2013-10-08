requires 'perl', '5.008001';
requires 'URI::Escape';
requires 'Exporter';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Time';
};

