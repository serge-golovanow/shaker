package Checking;

################################################################################
# Checking - CLASSE -  Représente une verification à effectuer
# Serge Golovanow
# Ps et File en héritent
# Methodes :
#   new : constructeur
#   disp : ajoute un message
#   getdisp : retourne les messages
# Propriétés :
#   DISP : messages à afficher
################################################################################

use strict;

sub new {
  my ($class) = @_;     #arguments du constructeur
  
  my $this = {};
  bless($this,$class);
  $this->{DISP} = ''; 
  return $this;
}###############################################################################
 
################################################################################
sub disp {                                                             ## disp #
  my ($this,$msg) = @_;
  $this->{DISP} .= "$msg\n";
}###############################################################################  

sub getdisp {
  my ($this) = @_;
  return $this->{DISP};
}
1;