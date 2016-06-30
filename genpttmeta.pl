#!/usr/bin/env perl

use HTML::Parser() ;
use feature "switch";
use HTML::Entities;

my $p = HTML::Parser->new
( 
	api_version => 3,
	start_h => [\&start, "tagname, attr"],
	text_h => [\&text, "text"],
	#end_h   => [\&end,   "tagname"],
	#marked_sections => 1,
);


sub start 
{
	my ($tagname, $attr) = @_ ;

	if ($tagname eq 'meta')
	{

		if ($attr->{name} eq 'description')
		{
			$meta{description} = $attr->{content};
		}

		elsif ($attr->{property} eq 'og:title')
		{
			$meta{title} = $attr->{content};
		}

	}

	elsif ($attr->{class} eq 'article-meta-tag')
	{
		$class{name} = 1;
	}

	elsif ($attr->{class} eq 'article-meta-value')
	{
		$class{value} = 1;
	}

}


sub text
{
	my $text = shift;

	if ($class{name} == 1)
	{
		$class{name} = $text;
	}
	elsif ($class{value} == 1)
	{
		$meta{ $class{name} } = $text ;
		($class{name} , $class{value}) = (0,0);
	}
}


foreach my $file (@ARGV)
{

	my $flag_title = 0;
	local %meta, %class;

	$p->parse_file($file);

	foreach my $key (keys %meta)
	{
		$meta{$key} = encode_entities($meta{$key}, "\046\074\076\042");
		# encode `"&<>` 4 char
	}

	print <<SECT;

<h2>
<a href="$file">
$meta{title}
</a></h2>

<small>
<u>$meta{'作者'}</u>
@
$meta{'看板'}
@
$meta{'時間'}
</small>

<pre>
$meta{description}
</pre>

<hr>

SECT

}

exit


