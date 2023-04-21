data "template_file" "user_data" {
  template = file("${path.module}/user_data.tftpl")
  vars = {
    var1  = "var1"
    
  }
}
