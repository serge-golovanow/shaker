package Job;

################################################################################
# Job - CLASSE - Regroupe un ensemble de checkings liés à un job
# Serge Golovanow
# Methodes :
#   new : constructeur
#   getdisp : retourne les messages
#   check : lance un check pour tous les @CHECKINGS
#   addChecking : ajoute un @CHECKING
#   getCheckings : retourne @CHECKINGS
#   getName : retourne NAME
# Propriétés :
#   NAME : Nom du job
#   CHECKINGS : référence vers le tableau des objets Checking
################################################################################

use strict;
#use Data::Dumper;

################################################################################
sub new {
  my ($class, $name) = @_;
  my $this = {};
  bless($this,$class);
  $this->{NAME} = $name;
  my @checkings = ();
  $this->{CHECKINGS} = \@checkings;
  #$this->{DISP} = ''; #$this->{NAME}." : \n";
  return $this;
}###############################################################################

sub getdisp {
  my ($this) = @_;
  my $return;
  foreach(@{$this->{CHECKINGS}}) { $return .= $_->getdisp(); }
  
  return $return."\n";
}###############################################################################

################################################################################
sub check {
  my ($this) = @_;
  my $errors='';
  for (my $i=0;$i<@{$this->{CHECKINGS}};$i++) { 
    #$errors += $_->check;
    #$errors += (2 ** $i)*(@{$this->{CHECKINGS}}[$i]->check); #stockage en binaire codé décimal $errors += (2^$i)*($_->check)
    $errors .= @{$this->{CHECKINGS}}[$i]->check; #stockage en binaire format string
  } 
  return $errors; 
}###############################################################################

#SETTERS
sub addChecking {
  my ($this,$checking) = @_;
  push (@{$this->{CHECKINGS}},$checking) if $checking;
}###############################################################################

#GETTERS
sub getCheckings {
  my ($this) = @_;
  return $this->{CHECKINGS};
}###############################################################################

sub getName {
  my ($this) = @_;
  return $this->{NAME};
}###############################################################################

1;
