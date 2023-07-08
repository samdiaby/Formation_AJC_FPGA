`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Testbench permettant la lecture et l'ecriture d'une image dans des fichiers .txt
// Le testbench lit la donnee du fichier Image_in.txt, et place le signal input_data_valid
// a 1, et ecrit la donnee en sortie du module top dans le fichier Image_out.txt si le signal 
// output_data_valid vaut 1.
//
// Module top :
// Le module top appele est ecrit en vhdl. Lorsque le signal input_data_valid vaut 1,
// la sortie output_data prend la valeur de input_data et le signal output_data_valid
// est place a 1.
//
// entity top is
//	generic(
//		PX_SIZE : integer := 8        -- taille d'un pixel
//	);
//	port(
//		resetn	: in std_logic;
//		clk		: in std_logic;
//		input_data	        : in std_logic_vector(PX_SIZE-1 downto 0);  //pixel en entree
//		input_data_valid	: in std_logic;
//		output_data	        : out std_logic_vector(PX_SIZE-1 downto 0); //pixel en sortie
//		output_data_valid	: out std_logic
//	);
//end top;
//////////////////////////////////////////////////////////////////////////////////


module tb_read_write_image(   );
  
  
  //dimensions de l'image
  parameter IMAGE_WIDTH = 'd64;   
  parameter IMAGE_HEIGHT = 'd64;

  parameter hp = 5;           //demi periode de l'horloge
  parameter period = 2*hp;    //periode de l'horloge
  
  parameter PX_SIZE = 8;      //taille d'un pixel
  
  
  reg clk;
  reg resetn;
  
  reg  [PX_SIZE-1:0] input_data;    //pixel a envoyer au module top
  wire [PX_SIZE-1:0] output_data;   //pixel envoye par le module top
  reg  input_data_valid;        //indique que la donnee lue est valide
  wire output_data_valid;       //indique que la donne a ecrire est valide
  
  
  reg [PX_SIZE-1:0] file_data_read; //utilise pour la lecture de l'image
  integer input_file, output_file;  //pointer des fichiers
  
  
  reg [11:0] cpt_px_output;     //compteur de colnne pour l'ecriture
  reg [11:0] cpt_line_output;   //compteur de ligne pour l'ecriture
  
  
  //affectation des signaux du testbench avec les ports du module top
  text_image_reader #(
    //PARAMETRES
    .PX_SIZE(PX_SIZE)
  )
  text_image_reader(
    //PORTS IN/OUT
    .clk(clk), 
    .resetn(resetn), 
    .input_data(input_data), 
    .input_data_valid(input_data_valid), 
    .output_data(output_data), 
    .output_data_valid(output_data_valid)
    );
  
    
    //enabling the wave dump
    initial begin 
        $dumpfile("dump.vcd"); $dumpvars;
    end
  
  
  
  //generation de l'horloge
    initial begin
      clk = 1;
      forever begin
          #(hp) clk = ~clk;
       end
    end 
    
  
  //LECTURE DE L'IMAGE EN ENTREE
    initial begin
      
        input_data = 'd0;      //tous les bits de input_data sont place a 0
        input_data_valid = 0;
        resetn = 1;            // active le resetn
        #period; //attente d'une periode pour attendre plusieurs periodes on aurait pu ecrire : #(4*period); 
        resetn = 0;            // desactive le resetn
        
        #period; //attente d'une periode pour attendre plusieurs periodes on aurait pu ecrire : #(4*period); 
        
        input_file = $fopen("./Image_in.txt","r");   //ouverture du fichier en mode lecture
        
//        #(2*period);      //exemple pour attendre 2 periodes
        
        
        //verification que le fichier a bien ete ouvert
        if(input_file) $display("Input file opened\n");
        else $display("Input file not opened\n");
        
        
        while(!$feof(input_file)) begin     //lecture du fichier tant qu'on n'est pas arrive a la fin du fichier
            
            $fscanf(input_file, "%d", file_data_read);  // lecture de la valeur d'un pixel
            input_data = file_data_read;                // envoie du pixel au module top
            input_data_valid = 1;
            #period; //attente d'une periode pour attendre plusieurs periodes on aurait pu ecrire : #(4*period); 
            
        end
        
        $fclose(input_file);    //fermeture du fichier
        
    end
        
        
        
  //ECRITURE DE L'IMAGE EN SORTIE
    initial begin //partie du process qui ne sera faite qu'une seule fois
        
        cpt_px_output = 'd0;        //compteur de colonne, initialisation a 0
        cpt_line_output = 'd0;      //compteur de ligne, initialisation a 0
        
        output_file= $fopen("Image_out.txt","w");   //ouverture du fichier en mode ecriture, s'il n'existe pas deja il sera cree
        
        //verification que le fichier a bien ete ouvert
        if(output_file) $display("Output file opened\n");
        else $display("Output file not opened\n");
        
    
    forever begin  //partie du process qui va se repeter en boucle
         #(period); //attente d'une periode pour attendre plusieurs periodes on aurait pu ecrire : #(4*period); 
         
         if(cpt_line_output < IMAGE_HEIGHT) begin   //test pour verifier si on a fini d'ecrire l'image
            
                if(output_data_valid) begin                 // on n'ecrit le pixel que s'il est valide
                    $fwrite(output_file,"%d ",output_data); //ecriture du pixel dans le fichier
                    
                    if(cpt_px_output == IMAGE_WIDTH-1) begin    //si on arrive a la fin d'une ligne
                        $fwrite(output_file,"\n");              //ecriture du caractere de renvoie a la ligne dans le fichier
                        cpt_px_output = 0;                      //remise a 0 du compteur de pixel
                        cpt_line_output = cpt_line_output + 'd1;    //incrementation du compteur de ligne
                    end
                    else begin
                        cpt_px_output = cpt_px_output + 'd1;        //incrementation du compteur de colonne
                    end
                    
                end
            
            end 
            else 
                $fclose(output_file);   //fermeture du fichier
            
        end 
    end
    

endmodule