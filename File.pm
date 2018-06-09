package File;
our @ISA = "Checking";  #héritage

################################################################################
# File - CLASSE - Vérifications liées à un fichier
# Serge Golovanow
# Implémente Checking
# Methodes :
#   new : constructeur
#   check : effectue la vérification
#   setMtime : défini la propriété MTIME
#    disp : herité de Checking, ajoute un message
#    getdisp : herité de Checking, retourne les messages
# Propriétés :
#   FILE : fichier dont il faut vérifier l'existence
#   MTIME : secondes écoulées depuis la derniere modif du fichier
#    DISP : hérité de Checking, message à afficher
################################################################################

use strict;
use POSIX qw(strftime);

################################################################################
sub new {
  my ($class,$file) = @_;              #arguments du constructeur
  
  if (!$file) { return undef; }
  
  my $this = {};
  bless($this,$class);
  
  $this->{FILE} = $file;
  $this->{MTIME} = undef; 
  #$this->{DISP} = '';  # hérité de Checking
  
  return $this;
}###############################################################################

################################################################################
sub check {
  my ($this) = @_;
  $this->{DISP} = '';
  my $errors=0;
  my @stat = stat($this->{FILE}); 
  if (!(@stat)) { $this->disp(" [-] File NOT found : $this->{FILE}"); $errors+=1; }
  else {
    my $mtime = $stat[9]; #strftime('%b %d %H:%M:%S', localtime($stat[9]));
    my $ftime = strftime('%b %d %H:%M:%S', localtime($mtime));
    if ($this->{MTIME}) {
      my $time = (time - $mtime);
        if ($time <= $this->{MTIME}) { $this->disp("  +  File $this->{FILE} last write time less than $this->{MTIME} sec ($time sec : $ftime)"); }
        else { $this->disp(" [-] File $this->{FILE} last write time greater than $this->{MTIME} sec ($time sec : $ftime)"); $errors+=1; }      
    }
    else { $this->disp("  +  File found : $this->{FILE} ($ftime)"); }
  }
  return $errors;
}###############################################################################

#SETTERS
sub setMtime {
  my ($this,$mtime) = @_;
  return undef if $mtime =~ /^\d+$/;
  $this->{MTIME} = $mtime if $mtime;
}###############################################################################

1;
