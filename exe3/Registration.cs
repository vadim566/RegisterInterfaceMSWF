using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace exe3
{
    public partial class Registration : Form
    {
        string connectionString = @"Data Source=DESKTOP-5A4RC55\SQLEXPRESS;
                                   Initial Catalog=sql_advanced;
                                    Integrated Security=True";
        public Registration()
        {
            InitializeComponent();

            //use validate procedure
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                ///create list of labels of questions
                Queue<System.Windows.Forms.Label> labelList = new Queue<System.Windows.Forms.Label>();
                //append it into the list
                labelList.Enqueue(q1);
                labelList.Enqueue(q2);
                labelList.Enqueue(q3);
                labelList.Enqueue(q4);
                labelList.Enqueue(q5);


                
                DataTable dt = new DataTable();

                SqlDataAdapter adapter = new SqlDataAdapter();
                adapter = new SqlDataAdapter("SELECT question FROM loginQuestion ", conn);


                adapter.Fill(dt);

                System.Windows.Forms.Label tmp= new Label();
                foreach (DataRow row in dt.Rows)
                {

                    labelList.Dequeue().Text = row.ItemArray[0].ToString();
                     

                }
                


            }
        }

        private void Registration_Load(object sender, EventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void label5_Click(object sender, EventArgs e)
        {

        }

        private void label6_Click(object sender, EventArgs e)
        {
            
        }

        private void label7_Click(object sender, EventArgs e)
        {

        }

        private void label9_Click(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                //
                try
                {

                    using (SqlCommand cmd = new SqlCommand("registerNewUser", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@email", SqlDbType.VarChar).Value = emailTextField.Text.ToString();
                        cmd.Parameters.Add("@password", SqlDbType.VarChar).Value = loginPasswordField.Text.ToString();
                        cmd.Parameters.Add("@name", SqlDbType.VarChar).Value = nameTextField.Text.ToString();
                        cmd.Parameters.Add("@lastname", SqlDbType.VarChar).Value = lastNameTextField.Text.ToString();
                        cmd.Parameters.Add("@birthday", SqlDbType.DateTime).Value = birthdayDatepicker.Value;
                        cmd.Parameters.Add("@q1", SqlDbType.VarChar).Value = q1lTextField.Text.ToString();
                        cmd.Parameters.Add("@q2", SqlDbType.VarChar).Value = q2lTextField.Text.ToString();
                        cmd.Parameters.Add("@q3", SqlDbType.VarChar).Value = q3lTextField.Text.ToString();
                        cmd.Parameters.Add("@q4", SqlDbType.VarChar).Value = q4lTextField.Text.ToString();
                        cmd.Parameters.Add("@q5", SqlDbType.VarChar).Value = q5lTextField.Text.ToString();
                        cmd.ExecuteNonQuery();

                    }
                }
                catch
                {
                    MessageBox.Show("Fill all Text Fields !");

                }
                finally
                {


                    //data set to retrive the returned values
                    DataTable dt = new DataTable();


                    //use validate procedure
                    SqlDataAdapter adapter1 = new SqlDataAdapter();

                    adapter1 = new SqlDataAdapter("select * from users where email=@email ", conn);
                    adapter1.SelectCommand.Parameters.AddWithValue("@email", emailTextField.Text.ToString());

                    adapter1.Fill(dt);

                    if (dt.Rows.Count == 1)
                    {
                        MessageBox.Show("Registration Complete !");
                        this.Close();


                    }
                    else
                    {
                        MessageBox.Show("Try again!");

                    }
                }

            }
        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void q1lTextField_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
