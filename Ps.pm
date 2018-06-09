package Ps;
our @ISA = "Checking";  #héritage

################################################################################
# Ps - CLASSE - Représente un ensemble de vérifications liées à un processus Unix
# Serge Golovanow
# Implémente Checking
# Methodes :
#   new : constructeur
#   check : effectue les vérifications
#   addBase : ajoute un @BASES
#   addGrep : ajoute un @GREPS
#   setMin : défini MIN
#   setMax : défini MAX
#    disp : herité de Checking, ajoute un message
#    getdisp : herité de Checking, retourne les messages
# Propriétés :
#   GREPS : référence vers le tableau des | grep à appliquer à la commande ps
#   MIN : minimum de process à trouver, sinon erreur (peut etre undef)
#   MAX : maximum       "         "       "           "         "
#   BASES : référence vers le tableau des bases Progress pour lesquelles les connexions de ce processus doivent etre listées
#    DISP : hérité de Checking, message à afficher
################################################################################

use strict;

################################################################################
sub new {                                                               ## new #
  my ($class) = @_;              #arguments du constructeur
  
  my $this = {};
  bless($this,$class);
  
  my @greps = ();
  $this->{GREPS} = \@greps;
  $this->{MIN} = undef;
  $this->{MAX} = undef;
  my @bases = ();
  $this->{BASES} = \@bases;
  #$this->{DISP} = ''; # hérité de Checking
  
  return $this;
}###############################################################################



################################################################################
sub check {                                                           ## check #
  my ($this) = @_;
  $this->{DISP} = '';
  my $errors=0;
  
## Liste des processus
  my $command='ps -ef | grep -v grep';
  foreach (@{$this->{GREPS}}) {
    $_ =~ s/'"'/'\"'/;       #Echappement des "
    $command .= " | grep \"$_\"";
  }
  #my $result = `$command`;
  my @ps = split("\n",`$command`);
  #my $count = @ps; #nombre de processus trouvés ; pas utile
  
  my @pids; 
  
  if ( (!defined($this->{MIN}) || @ps ge $this->{MIN}) && (!defined($this->{MAX}) || @ps le $this->{MAX}) ) {
    $this->disp('  +  '.scalar @ps.' process found');
  }
  else {
    $this->disp(' [-] '.scalar @ps.' process found (must be'.($this->{MIN} ? " >=$this->{MIN}" : '').($this->{MAX} ? " <=$this->{MAX}" : '').')');
    $errors++;
  }
  
  foreach(@ps) {          #pour chaque process trouvé
    if ($_ =~ / *(\S+) +(\d+) +\d+ +\d+ +(\d\d:\d\d(:\d\d)?|[A-Z][a-z]{2} ?\d{2}) +\S+ +\S+ +(.*)/) {
      my $com = '';
      if ($5) { $com = $5; $com =~ s:^/\S*/::g ; }
      $this->disp("\t$1\t$2\t$3\t$com");
      push(@pids,$2) if $2;         #Rajout du PID dans le tableau @pids
    }
    else { $this->disp("?\t$_"); }
  }
  
## Liste des connexions au bases + liste des locks pour ces connexions
  if (@{$this->{BASES}}) {
    foreach(@pids) {      #pour chaque PID trouvé précédemment
      my $pid = $_;
      #print "Checking base connections for pid $pid, please wait...";   #nécessite un  print "\r";
      
      my @connexions;
      my @allocks;
      #if (@{$this->{BASES}}) {
      foreach(@{$this->{BASES}}) {
        my $base = $_;
        my @connexion = split("\n",`proshut $base -C list | grep -E "\s*$pid [A-Z][a-z]{2}" | sed s/no//g`);   #chaque ligne est mise dans un élement du tableau
        foreach(@connexion) {
          push(@connexions,"$base\t$_"); #Rajout de la connexion au tableau (qui sera affiché globalement)
          $_ =~ /^\s*(\d+)\s/;  #extraction de l'usernum pour checker les locks
          my $user = $1;                          #########      <---  $1   ###########
          my $lock = `chk_locks.sh $base $user`;
          my @locks = split("\n",$lock);
          push(@allocks,@locks);
        }
      }#fin foreach bases
      #print "\r";
      
      #on peut en fait avoir un nombre supérieur de connexions.. donc pas de verif (pquoi pas si @connexions<$m?)
      #if ($m eq @connexions) { report(" (+)  $m base connections found for process $pid          "); }
      #else { report(" [-]  $ccount base connections found for process $pid            "); $errors++; }
      $this->disp("  >  ".scalar @connexions." base connections found for process $pid :         ");
      if (@connexions) { $this->disp("\t     base       usr    pid    time of login           user id     tty"); }
      foreach(@connexions) { $this->disp("\t$_"); }
      if (@allocks) {   #S'il y a des locks à afficher
        $this->disp("  >  ".scalar @allocks." locks for process $pid :   ");
        $this->disp("\t    base         Usr Name         iREcid Table TableName    Flags");
        foreach(@allocks) { $this->disp("\t$_"); }
      }
    }#fin foreach @pids
  }
  
  return $errors;
}###############################################################################

#SETTERS
sub addBase {
  my ($this,$base) = @_;
  push @{$this->{BASES}},$base if $base;
}###############################################################################

sub setMin {
  my ($this,$min) = @_;
  $this->{MIN} = $min if $min;
}###############################################################################

sub setMax {
  my ($this,$max) = @_;
  $this->{MAX} = $max if $max;
}###############################################################################

sub addGrep {
  my ($this,$grep) = @_;
  push (@{$this->{GREPS}},$grep) if $grep;
}###############################################################################

#GETTERS
sub getGreps {
  my ($this) = @_;
  return $this->{GREPS}
}###############################################################################


1;
