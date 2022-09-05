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
using static System.Windows.Forms.VisualStyles.VisualStyleElement.Rebar;

namespace exe3
{
    public partial class PasswordReset : Form
    {
        string connectionString = @"Data Source=DESKTOP-5A4RC55\SQLEXPRESS;
                                   Initial Catalog=sql_advanced;
                                    Integrated Security=True";

         int[]  q_num = { -1,-1,-1};
        public PasswordReset()
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
           



                DataTable dt = new DataTable();

                SqlDataAdapter adapter = new SqlDataAdapter();
                adapter = new SqlDataAdapter("SELECT question FROM loginQuestion ", conn);


                adapter.Fill(dt);


                //randomize 3 number between 5 without repeats

                var rand = new Random();
                Queue<int> listNumbers = new Queue<int>();
                int number;
                //push 3 random numbers
                for (int i = 0; i < 3; i++)
                {
                    do
                    {
                        number = rand.Next(0, 4);
                    } while (listNumbers.Contains(number));
                    listNumbers.Enqueue(number);


                }

                //pop 3 random genrated numbers into text , the random num is qid in db.loginrest
                for (int i = 0; i < 3; i++)
                {
                    q_num[i] = listNumbers.Dequeue();
                    labelList.Dequeue().Text = dt.Rows[q_num[i]].ItemArray[0].ToString();

                }
              





            }
        }

        private void button1_Click(object sender, EventArgs e)
        {

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                //
                //data set to retrive the returned values
                
                DataTable dt = new DataTable();
                try
                {

                    SqlDataAdapter adapter1 = new SqlDataAdapter();

                    adapter1 = new SqlDataAdapter("select * from loginrest where email=@email ", conn);
                    adapter1.SelectCommand.Parameters.AddWithValue("@email", emailTextField.Text.ToString());

                    adapter1.Fill(dt);



                }
                catch
                {
                    MessageBox.Show("Try again! Something went wrong");
                }

                finally
                {
                    if (dt.Rows.Count == 5 
                        && dt.Rows[this.q_num[0]].ItemArray[1].ToString()==q1lTextField.Text.ToString()
                        && dt.Rows[this.q_num[1]].ItemArray[1].ToString() == q2lTextField.Text.ToString()
                        && dt.Rows[this.q_num[2]].ItemArray[1].ToString() == q3lTextField.Text.ToString() )
                    {
                     

                        using (SqlCommand cmd = new SqlCommand("UPDATE login set password=@password where  email=@email", conn))
                        {
                            cmd.Parameters.Add("@email", SqlDbType.VarChar).Value = emailTextField.Text.ToString();
                            cmd.Parameters.Add("@password", SqlDbType.VarChar).Value = resetPasswordField.Text.ToString();
                            cmd.ExecuteNonQuery();
                        }
                   
                        MessageBox.Show("password changed to "+ resetPasswordField.Text.ToString());
                        this.Close();


                    }
                    else
                    {
                        MessageBox.Show("Try again! Bad answers to questions");

                    }
                }
           }






                }

        private void q1lTextField_TextChanged(object sender, EventArgs e)
        {

        }

        private void emailTextField_TextChanged(object sender, EventArgs e)
        {

        }

        private void loginPasswordField_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
