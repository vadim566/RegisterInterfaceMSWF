using System;
using System.CodeDom.Compiler;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.ListView;

namespace exe3
{
    public partial class Form1 : Form
    {
        
        string connectionString = @"Data Source=DESKTOP-5A4RC55\SQLEXPRESS;
                                   Initial Catalog=sql_advanced;
                                    Integrated Security=True";
        public Form1()
        {
            

            InitializeComponent();
           
        }

        private void button1_Click(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void button1_Click_1(object sender, EventArgs e)
        {

        }

        private void button2_Click(object sender, EventArgs e)
        {
            Registration form = new Registration();
            form.Show();
        }

        private void button3_Click(object sender, EventArgs e)
        {


            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                // Do work here; connection closed on following line.


                //use login procedure


                try
                {

                    using (SqlCommand cmd = new SqlCommand("loginProcedure", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@email", SqlDbType.VarChar).Value = EmailLoginField.Text.ToString();
                        cmd.Parameters.Add("@password", SqlDbType.VarChar).Value = loginPasswordField.Text.ToString();
                        cmd.ExecuteNonQuery();
                    }
                }
                catch
                {
                    

                }
                finally
                {

              
                //data set to retrive the returned values
                DataTable dt = new DataTable();


                //use validate procedure
                SqlDataAdapter adapter1 = new SqlDataAdapter();
              
                adapter1 = new SqlDataAdapter("EXECUTE loginValidation @email ", conn);
                adapter1.SelectCommand.Parameters.AddWithValue("@email", EmailLoginField.Text.ToString());

                adapter1.Fill(dt);
                 
                if (dt.Rows.Count == 1)
                {
                    loginSuccses form = new loginSuccses();
                    form.Show();
                    this.Hide();

                }
                else
                {
                    MessageBox.Show("Couldnt Connect ,Check Your Email and Password  !");
                      
                    }
                }
            }



        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged_1(object sender, EventArgs e)
        {
           // string loginEmail= EmailLoginField.Text.ToString();
            //loginPasswordField.Text = loginEmail;

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {
            //string loginPassword = EmailLoginField.Text.ToString();
        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            PasswordReset form=new PasswordReset();
            form.Show();
        }
    }
}
